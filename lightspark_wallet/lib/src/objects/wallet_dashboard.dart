import 'balances.dart';
import 'wallet_status.dart';
import 'wallet_to_payment_requests_connection.dart';
import 'wallet_to_transactions_connection.dart';

class WalletDashboard {
  final String id;
  final WalletStatus status;
  final Balances? balances;
  final WalletToTransactionsConnection recentTransactions;
  final WalletToPaymentRequestsConnection paymentRequests;

  WalletDashboard({
    required this.id,
    required this.status,
    this.balances,
    required this.recentTransactions,
    required this.paymentRequests,
  });
}
