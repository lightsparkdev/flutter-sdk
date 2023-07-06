import 'package:flutter/material.dart';
import 'package:lightspark_wallet/lightspark_wallet.dart';
import 'package:lightspark_wallet_example/src/model/lightspark_client_notifier.dart';
import 'package:lightspark_wallet_example/src/screens/account_screen.dart';
import 'package:lightspark_wallet_example/src/screens/request_payment_screen.dart';
import 'package:lightspark_wallet_example/src/screens/send_payment_screen.dart';
import 'package:provider/provider.dart';
import '../components/transaction_row.dart';
import '../utils/currency.dart';

class HomeScreen extends StatefulWidget {
  final Future<void> Function() onLogout;
  final LoginCallback onLogin;
  const HomeScreen({super.key, required this.onLogout, required this.onLogin});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final testTransaction = IncomingPayment(
  'test',
  '2023-08-01T04:32:01Z',
  '2023-08-01T04:32:01Z',
  TransactionStatus.SUCCESS,
  CurrencyAmount(
    50000,
    CurrencyUnit.SATOSHI,
    CurrencyUnit.USD,
    132,
    132,
  ),
  'IncomingPayment',
  '2023-08-01T04:33:01Z',
  '4894089ffnrjfh4y74u',
  '',
);

class _HomeScreenState extends State<HomeScreen> {
  WalletDashboard? _dashboard;
  WalletStatus? _forcedStatus;

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
    return Center(child: _buildBody(context));
  }

  Widget _buildBody(BuildContext context) {
    if (_dashboard == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dashboard!.status != WalletStatus.READY || _forcedStatus != null) {
      return _buildNotInitialized(context, _forcedStatus ?? _dashboard!.status);
    }

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(0),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                _dashboard!.balances!.ownedBalance.preferredCurrencyUnit
                    .toTextValue(
                  _dashboard!
                      .balances!.ownedBalance.preferredCurrencyValueRounded,
                ),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                CurrencyUnit.SATOSHI.toAbbreviatedValue(
                  _dashboard!.balances!.ownedBalance.originalUnit
                      .toSats(_dashboard!.balances!.ownedBalance.originalValue)
                      .round(),
                ),
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(SendPaymentScreen.route());
                    },
                    child: const Text('Send'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(RequestPaymentScreen.route());
                    },
                    child: const Text('Receive'),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _dashboard!.recentTransactions.count + 7,
            itemBuilder: (context, index) {
              final transaction = (_dashboard!.recentTransactions.entities +
                  [
                    testTransaction,
                    testTransaction,
                    testTransaction,
                    testTransaction,
                    testTransaction,
                    testTransaction,
                    testTransaction
                  ])[index];
              return TransactionRow(transaction: transaction);
            },
          ),
        )
      ],
    );
  }

  Widget _buildNotInitialized(BuildContext context, WalletStatus status) {
    const statusMessage = {
      WalletStatus.NOT_SETUP: 'Your wallet needs to be deployed.',
      WalletStatus.DEPLOYING: 'Your wallet is deploying...',
      WalletStatus.DEPLOYED: 'Your wallet needs to be initialized.',
      WalletStatus.INITIALIZING: 'Your wallet is initializing...',
      WalletStatus.FAILED:
          'Something went wrong with your wallet. Try re-deploying it.',
    };

    const buttonText = {
      WalletStatus.NOT_SETUP: 'Deploy Wallet',
      WalletStatus.DEPLOYED: 'Initialize Wallet',
      WalletStatus.FAILED: 'Re-deploy Wallet',
    };

    final isLoading =
        status == WalletStatus.DEPLOYING || status == WalletStatus.INITIALIZING;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          statusMessage[status] ?? 'Wallet status unknown',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () async {
                  final client = Provider.of<LightsparkClientNotifier>(
                    context,
                    listen: false,
                  ).value;
                  if (status == WalletStatus.DEPLOYED) {
                    setState(() {
                      _forcedStatus = WalletStatus.INITIALIZING;
                    });
                    final keyPair = await generateRsaKeyPair();
                    print('Public Key: ${keyPair.publicKey}');
                    print('Private Key: ${keyPair.privateKey}');
                    await client.initializeWalletAndAwaitReady(
                      KeyType.RSA_OAEP,
                      keyPair.publicKey,
                      keyPair.privateKey,
                    );
                  } else {
                    setState(() {
                      _forcedStatus = WalletStatus.DEPLOYING;
                    });
                    await client.deployWalletAndAwaitDeployed();
                  }
                  setState(() {
                    _forcedStatus = null;
                  });
                  await _loadDashboard();
                },
                child: Text(buttonText[status] ?? 'Deploy Wallet'),
              ),
      ],
    );
  }
}
