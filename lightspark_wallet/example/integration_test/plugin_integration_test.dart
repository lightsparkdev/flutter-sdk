// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://docs.flutter.dev/cookbook/testing/integration/introduction

// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:lightspark_wallet/lightspark_wallet.dart';

// Fetch account info from environment
final String accountId = Platform.environment['LIGHTSPARK_ACCOUNT_ID_flutter_test']!;
final String jwt = Platform.environment['LIGHTSPARK_JWT_flutter_test']!;
final String signingPublicKey =
    Platform.environment['LIGHTSPARK_WALLET_PUB_KEY_flutter_test']!;
final String signingPrivateKey =
    Platform.environment['LIGHTSPARK_WALLET_PRIV_KEY_flutter_test']!;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('getPlatformVersion test', (WidgetTester tester) async {
    final LightsparkWallet plugin = LightsparkWallet();
    final String? version = await plugin.getPlatformVersion();
    // The version string depends on the host platform running the test, so
    // just assert that some non-empty string is returned.
    expect(version?.isNotEmpty, true);
  });

  testWidgets('Fetch a known wallet dashboard', (WidgetTester tester) async {
    final client = LightsparkWalletClient();
    await client.loginWithJwt(accountId, jwt, InMemoryJwtStorage());
    final dashboard = await client.getWalletDashboard();
    expect(dashboard, isNotNull);
    expect(dashboard?.status, WalletStatus.READY);
    expect(dashboard?.recentTransactions.count, isPositive);
  });

  testWidgets('key generation', (widgetTester) async {
    final keyPair = await generateRsaKeyPair();
    expect(keyPair, isNotNull);
    expect(keyPair.publicKey, startsWith('-----BEGIN RSA PUBLIC KEY-----'));
    expect(keyPair.privateKey, startsWith('-----BEGIN RSA PRIVATE KEY-----'));
    print(
        'Generated: {\npublicKey: ${keyPair.publicKey}\nprivateKey: ${keyPair.privateKey}\n}');
  });

  testWidgets('get bitcoin fee estimates', (widgetTester) async {
    final client = LightsparkWalletClient();
    await client.loginWithJwt(accountId, jwt, InMemoryJwtStorage());
    final feeEstimates = await client.getBitcoinFeeEstimate();
    expect(feeEstimates, isNotNull);
    expect(feeEstimates.feeFast.originalValue, isPositive);
    expect(feeEstimates.feeMin.originalValue, isPositive);
  });

  testWidgets('list current wallet payment requests', (widgetTester) async {
    final client = LightsparkWalletClient();
    await client.loginWithJwt(accountId, jwt, InMemoryJwtStorage());
    final currentWallet = (await client.getCurrentWallet())!;
    expect(currentWallet, isNotNull);
    final paymentRequests = await currentWallet.getPaymentRequests(client);
    expect(paymentRequests, isNotNull);
    expect(paymentRequests.count, isPositive);
  });

  testWidgets('get transactions with paging', (widgetTester) async {
    final client = LightsparkWalletClient();
    await client.loginWithJwt(accountId, jwt, InMemoryJwtStorage());
    final currentWallet = (await client.getCurrentWallet())!;
    expect(currentWallet, isNotNull);

    const pageSize = 5;
    var iterations = 0;
    var hasNext = true;
    String? after;
    while (hasNext && iterations < 30) {
      iterations++;
      final transactions = await currentWallet.getTransactions(
        client,
        first: pageSize,
        after: after,
      );
      expect(transactions, isNotNull);
      expect(transactions.count, isPositive);
      print('Got ${transactions.entities.length} / ${transactions.count} transactions');
      if (transactions.pageInfo.hasNextPage == true) {
        expect(transactions.pageInfo.endCursor, isNotNull);
        after = transactions.pageInfo.endCursor;
        hasNext = true;
        print('    and we have more!');
      } else {
        hasNext = false;
        print('    and we are done!');
      }
    }
  });

  testWidgets('get transactions in the last day', (widgetTester) async {
    final client = LightsparkWalletClient();
    await client.loginWithJwt(accountId, jwt, InMemoryJwtStorage());
    final currentWallet = (await client.getCurrentWallet())!;
    expect(currentWallet, isNotNull);
    final transactions = await currentWallet.getTransactions(
      client,
      first: 5,
      after: null,
      createdAfterDate: DateTime.now().toUtc().subtract(const Duration(days: 1)).toIso8601String(),
    );
    expect(transactions, isNotNull);
    print('There were ${transactions.count} transactions in the last day.');
  });

  testWidgets('get most recent transaction details', (widgetTester) async {
    final client = LightsparkWalletClient();
    await client.loginWithJwt(accountId, jwt, InMemoryJwtStorage());
    final currentWallet = (await client.getCurrentWallet())!;
    expect(currentWallet, isNotNull);
    final transactions = await currentWallet.getTransactions(
      client,
      first: 1,
    );
    expect(transactions, isNotNull);
    expect(transactions.count, isPositive);
    final transaction = transactions.entities.first;
    expect(transaction, isNotNull);
    final transactionDetails = await client.executeRawQuery(Transaction.getTransactionQuery(transaction.id));
    expect(transactionDetails, isNotNull);
    expect(transactionDetails.id, transaction.id);
  });

  testWidgets('create and decode a payment request', (widgetTester) async {
    final client = LightsparkWalletClient();
    await client.loginWithJwt(accountId, jwt, InMemoryJwtStorage());
    final invoice = await client.createInvoice(42000, memo: 'Pizza!');
    expect(invoice, isNotNull);
    print('Encoded invoice: ${invoice.encodedPaymentRequest}');

    final decodedInvoice = await client.decodeInvoice(invoice.encodedPaymentRequest);
    expect(decodedInvoice, isNotNull);
    expect(decodedInvoice.amount, invoice.amount);
    expect(decodedInvoice.memo, invoice.memo);
  });

  testWidgets('create a funding address', (widgetTester) async {
    final client = LightsparkWalletClient();
    await client.loginWithJwt(accountId, jwt, InMemoryJwtStorage());
    await client.loadWalletSigningKey(signingPrivateKey);
    final address = await client.createBitcoinFundingAddress();
    expect(address, isNotNull);
    print('Created funding address: $address');
  });

  testWidgets('get lightning fee estimate for invoice', (widgetTester) async {
    final client = LightsparkWalletClient();
    await client.loginWithJwt(accountId, jwt, InMemoryJwtStorage());
    const invoice = 'lnbcrt1pjr8xwypp5xqj2jfpkz095s8zu57ktsq8vt8yazwcmqpcke9pvl67ne9cpdr0qdqj2a5xzumnwd6hqurswqcqzpgxq9z0rgqsp55hfn0caa5sexea8u979cckkmwelw6h3zpwel5l8tn8s0elgwajss9q8pqqqssqefmmw79tknhl5xhnh7yfepzypxknwr9r4ya7ueqa6vz20axvys8se986hwj6gppeyzst44hm4yl04c4dqjjpqgtt0df254q087sjtfsq35yagj';
    final estimate = await client.getLightningFeeEstimateForInvoice(invoice, 100000);
    expect(estimate, isNotNull);
    print('Fee estimate: ${estimate.originalValue} ${estimate.originalUnit.name}}');
  });

  testWidgets('get lightning fee estimate for node', (widgetTester) async {
    final client = LightsparkWalletClient();
    await client.loginWithJwt(accountId, jwt, InMemoryJwtStorage());
    const destinationPublicKey = '03031864387b8f63ca4ffaeecd8aa973364bf31964f19c74343037b18d75e2d4f7';
    final estimate = await client.getLightningFeeEstimateForNode(destinationPublicKey, 100000);
    expect(estimate, isNotNull);
    print('Fee estimate: ${estimate.originalValue} ${estimate.originalUnit.name}}');
  });

  testWidgets('test paying a test mode invoice', (widgetTester) async {
    final client = LightsparkWalletClient();
    await client.loginWithJwt(accountId, jwt, InMemoryJwtStorage());
    await client.loadWalletSigningKey(signingPrivateKey);
    final invoice = (await client.createTestModeInvoice(100000, memo: 'test invoice'))!;
    print(invoice);
    final outgoingPayment = await client.payInvoiceAndAwaitResult(invoice, 10000);
    expect(outgoingPayment, isNotNull);
    expect(outgoingPayment.status, TransactionStatus.SUCCESS);
  });

  testWidgets('test creating a test mode payment', (widgetTester) async {
    final client = LightsparkWalletClient();
    await client.loginWithJwt(accountId, jwt, InMemoryJwtStorage());
    await client.loadWalletSigningKey(signingPrivateKey);
    final invoice = await client.createInvoice(100000000, memo: 'test invoice');
    expect(invoice, isNotNull);
    final payment = await client.createTestModePayment(invoice.encodedPaymentRequest);
    expect(payment, isNotNull);
    expect(payment!.status, isIn({TransactionStatus.SUCCESS, TransactionStatus.PENDING}));
  });
}
