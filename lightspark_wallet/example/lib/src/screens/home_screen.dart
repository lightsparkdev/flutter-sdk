import 'package:flutter/material.dart';
import 'package:lightspark_wallet/lightspark_wallet.dart';
import 'package:lightspark_wallet_example/src/model/lightspark_client_notifier.dart';
import 'package:provider/provider.dart';
import '../components/transaction_row.dart';
import '../utils/currency.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final testTransaction = IncomingPayment(
  "test",
  "2023-08-01T04:32:01Z",
  "2023-08-01T04:32:01Z",
  TransactionStatus.SUCCESS,
  CurrencyAmount(
    50000,
    CurrencyUnit.SATOSHI,
    CurrencyUnit.USD,
    132,
    132,
  ),
  "IncomingPayment",
  "2023-08-01T04:33:01Z",
  "4894089ffnrjfh4y74u",
  "",
);

class _HomeScreenState extends State<HomeScreen> {
  WalletDashboard? _dashboard;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final client = Provider.of<LightsparkClientNotifier>(
      context,
      listen: false,
    ).value;
    final dashboard = await client.getWalletDashboard();
    setState(() {
      _dashboard = dashboard;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_dashboard == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            'Your wallet is ${_dashboard!.status.name}',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Balance(
                  balance: _dashboard!.balances?.ownedBalance,
                  name: 'Owned Balance'),
              Balance(
                  balance: _dashboard!.balances?.availableToSendBalance,
                  name: 'Available to Send'),
              Balance(
                  balance: _dashboard!.balances?.availableToWithdrawBalance,
                  name: 'Available to Withdraw'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _dashboard!.recentTransactions.count + 3,
              itemBuilder: (context, index) {
                final transaction =
                    (_dashboard!.recentTransactions.entities + [testTransaction, testTransaction, testTransaction])[index];
                return TransactionRow(transaction: transaction);
              },
            ),
          )
        ],
      ),
    );
  }
}

class Balance extends StatelessWidget {
  const Balance({
    super.key,
    required CurrencyAmount? balance,
    required String name,
  })  : _balance = balance,
        _name = name;

  final CurrencyAmount? _balance;
  final String _name;

  @override
  Widget build(BuildContext context) {
    if (_balance == null) {
      return const Spacer();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              _name,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 16),
            Text(
              _balance!.preferredCurrencyUnit
                  .toTextValue(_balance!.preferredCurrencyValueRounded),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              _balance!.originalUnit.toTextValue(_balance!.originalValue),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
