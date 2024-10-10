// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import '../requester/query.dart';
import './currency_amount.dart';
import './entity.dart';
import './on_chain_transaction.dart';
import './transaction.dart';
import './transaction_status.dart';

/// This object represents an L1 withdrawal from your Lightspark Node to any Bitcoin wallet. You can retrieve this object to receive detailed information about any L1 withdrawal associated with your Lightspark Node or account.
class Withdrawal implements OnChainTransaction, Transaction, Entity {
  /// The unique identifier of this entity across all Lightspark systems. Should be treated as an opaque string.
  @override
  final String id;

  /// The date and time when this transaction was initiated.
  @override
  final String createdAt;

  /// The date and time when the entity was last updated.
  @override
  final String updatedAt;

  /// The current status of this transaction.
  @override
  final TransactionStatus status;

  /// The amount of money involved in this transaction.
  @override
  final CurrencyAmount amount;

  /// The height of the block that included this transaction. This will be zero for unconfirmed transactions.
  @override
  final int blockHeight;

  /// The Bitcoin blockchain addresses this transaction was sent to.
  @override
  final List<String> destinationAddresses;

  /// The typename of the object
  @override
  final String typename;

  /// The date and time when this transaction was completed or failed.
  @override
  final String? resolvedAt;

  /// The hash of this transaction, so it can be uniquely identified on the Lightning Network.
  @override
  final String? transactionHash;

  /// The fees that were paid by the node for this transaction.
  @override
  final CurrencyAmount? fees;

  /// The hash of the block that included this transaction. This will be null for unconfirmed transactions.
  @override
  final String? blockHash;

  /// The number of blockchain confirmations for this transaction in real time.
  @override
  final int? numConfirmations;

  Withdrawal(
    this.id,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.amount,
    this.blockHeight,
    this.destinationAddresses,
    this.typename,
    this.resolvedAt,
    this.transactionHash,
    this.fees,
    this.blockHash,
    this.numConfirmations,
  );

  static Query<Withdrawal> getWithdrawalQuery(String id) {
    return Query(
      '''
query GetWithdrawal(\$id: ID!) {
    entity(id: \$id) {
        ... on Withdrawal {
            ...WithdrawalFragment
        }
    }
}

$fragment  
''',
      (json) => Withdrawal.fromJson(json['entity']),
      variables: {'id': id},
    );
  }

  static Withdrawal fromJson(Map<String, dynamic> json) {
    return Withdrawal(
      json['withdrawal_id'],
      json['withdrawal_created_at'],
      json['withdrawal_updated_at'],
      TransactionStatus.values.asNameMap()[json['withdrawal_status']] ??
          TransactionStatus.FUTURE_VALUE,
      CurrencyAmount.fromJson(json['withdrawal_amount']),
      json['withdrawal_block_height'],
      List<String>.from(json['withdrawal_destination_addresses']),
      'Withdrawal',
      json['withdrawal_resolved_at'],
      json['withdrawal_transaction_hash'],
      (json['withdrawal_fees'] != null
          ? CurrencyAmount.fromJson(json['withdrawal_fees'])
          : null),
      json['withdrawal_block_hash'],
      json['withdrawal_num_confirmations'],
    );
  }

  static const fragment = r'''
fragment WithdrawalFragment on Withdrawal {
    __typename
    withdrawal_id: id
    withdrawal_created_at: created_at
    withdrawal_updated_at: updated_at
    withdrawal_status: status
    withdrawal_resolved_at: resolved_at
    withdrawal_amount: amount {
        __typename
        currency_amount_original_value: original_value
        currency_amount_original_unit: original_unit
        currency_amount_preferred_currency_unit: preferred_currency_unit
        currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
        currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
    }
    withdrawal_transaction_hash: transaction_hash
    withdrawal_fees: fees {
        __typename
        currency_amount_original_value: original_value
        currency_amount_original_unit: original_unit
        currency_amount_preferred_currency_unit: preferred_currency_unit
        currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
        currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
    }
    withdrawal_block_hash: block_hash
    withdrawal_block_height: block_height
    withdrawal_destination_addresses: destination_addresses
    withdrawal_num_confirmations: num_confirmations
}''';
}
