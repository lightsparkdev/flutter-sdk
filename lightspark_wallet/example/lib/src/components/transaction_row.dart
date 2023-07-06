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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _transaction.typeColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Icon(
                _transaction.typeIcon,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),
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
                _transaction.amount.preferredCurrencyUnit.toTextValue(
                  _transaction.amount.preferredCurrencyValueRounded,
                ),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                CurrencyUnit.SATOSHI.toTextValue(
                  _transaction.amount.originalUnit
                      .toSats(_transaction.amount.originalValue)
                      .round(),
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

  IconData get typeIcon {
    return switch (typename) {
      'IncomingPayment' => Icons.arrow_back,
      'OutgoingPayment' => Icons.arrow_forward,
      'Deposit' => Icons.arrow_circle_down,
      'Withdrawal' => Icons.arrow_circle_up,
      _ => Icons.help,
    };
  }

  Color get typeColor {
    return switch (typename) {
      'IncomingPayment' => const Color.fromARGB(0xFF, 0x17, 0xC2, 0x7C),
      'OutgoingPayment' => const Color.fromARGB(0xFF, 0, 0x66, 0xFF),
      'Deposit' => const Color.fromARGB(0xFF, 0x17, 0xC2, 0x7C),
      'Withdrawal' => const Color.fromARGB(0xFF, 0, 0x66, 0xFF),
      _ => Colors.grey,
    };
  }
}
