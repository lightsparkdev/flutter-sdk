import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lightspark_wallet/lightspark_wallet.dart';
import 'package:lightspark_wallet_example/src/utils/currency.dart';

class TransactionRow extends StatelessWidget {
  final Transaction _transaction;

  const TransactionRow({
    super.key,
    required Transaction transaction,
  }) : _transaction = transaction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.primary.withAlpha(20),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _transaction.typeString,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  DateFormat('MMM dd, hh:mma').format(
                    DateTime.parse(_transaction.createdAt).toLocal(),
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _transaction.amount.originalUnit.toTextValue(
                  _transaction.amount.originalValue,
                ),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                _transaction.amount.preferredCurrencyUnit.toTextValue(
                  _transaction.amount.preferredCurrencyValueRounded,
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension on Transaction {
  String get typeString {
    return switch (typename) {
      'IncomingPayment' => 'Received',
      'OutgoingPayment' => 'Sent',
      'Deposit' => 'Deposit',
      'Withdrawal' => 'Withdrawal',
      _ => 'Unknown',
    };
  }
}
