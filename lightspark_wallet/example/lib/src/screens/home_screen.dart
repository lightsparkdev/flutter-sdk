import 'package:flutter/material.dart';
import 'package:lightspark_wallet/lightspark_wallet.dart';
import 'package:lightspark_wallet_example/src/model/lightspark_client_notifier.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

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
            'Welcome ${_dashboard!.id}!',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
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
              _balance!.preferredCurrencyUnit.toTextValue(_balance!.preferredCurrencyValueRounded),
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

extension on CurrencyUnit {
  String get shortName {
    return switch (this) {
      CurrencyUnit.BITCOIN => 'BTC',
      CurrencyUnit.MILLIBITCOIN => 'mBTC',
      CurrencyUnit.MICROBITCOIN => 'μBTC',
      CurrencyUnit.NANOBITCOIN => 'nBTC',
      CurrencyUnit.SATOSHI => 'sat',
      CurrencyUnit.MILLISATOSHI => 'msat',
      CurrencyUnit.USD => 'USD',
      CurrencyUnit.FUTURE_VALUE => '',
    };
  }

  String toTextValue(int amount) {
    return switch (this) {
      CurrencyUnit.BITCOIN => '${amount.toStringAsFixed(8)} $shortName',
      CurrencyUnit.MILLIBITCOIN => '${amount.toStringAsFixed(5)} $shortName',
      CurrencyUnit.MICROBITCOIN => '${amount.toStringAsFixed(2)} $shortName',
      CurrencyUnit.NANOBITCOIN => '${amount.toStringAsFixed(0)} $shortName',
      CurrencyUnit.SATOSHI => '${amount.toStringAsFixed(3)} $shortName',
      CurrencyUnit.MILLISATOSHI => '${amount.toStringAsFixed(0)} $shortName',
      CurrencyUnit.USD => '\$${amount.toStringAsFixed(2)} $shortName',
      CurrencyUnit.FUTURE_VALUE => '',
    };
  }
}
