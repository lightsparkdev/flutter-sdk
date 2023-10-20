// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './on_chain_transaction.dart';
import './transaction.dart';
import './entity.dart';
import './currency_amount.dart';
import './transaction_status.dart';
import '../requester/query.dart';

/// This is an object representing a transaction which closes a channel on the Lightning Network. This operation allocates balances back to the local and remote nodes.
class ChannelClosingTransaction
    implements OnChainTransaction, Transaction, Entity {
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

  /// The fees that were paid by the wallet sending the transaction to commit it to the Bitcoin blockchain.
  @override
  final CurrencyAmount? fees;

  /// The hash of the block that included this transaction. This will be null for unconfirmed transactions.
  @override
  final String? blockHash;

  /// The number of blockchain confirmations for this transaction in real time.
  @override
  final int? numConfirmations;

  ChannelClosingTransaction(
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

  static Query<ChannelClosingTransaction> getChannelClosingTransactionQuery(
      String id) {
    return Query(
      '''
query GetChannelClosingTransaction(\$id: ID!) {
    entity(id: \$id) {
        ... on ChannelClosingTransaction {
            ...ChannelClosingTransactionFragment
        }
    }
}

$fragment  
''',
      (json) => ChannelClosingTransaction.fromJson(json['entity']),
      variables: {'id': id},
    );
  }

  static ChannelClosingTransaction fromJson(Map<String, dynamic> json) {
    return ChannelClosingTransaction(
      json['channel_closing_transaction_id'],
      json['channel_closing_transaction_created_at'],
      json['channel_closing_transaction_updated_at'],
      TransactionStatus.values
              .asNameMap()[json['channel_closing_transaction_status']] ??
          TransactionStatus.FUTURE_VALUE,
      CurrencyAmount.fromJson(json['channel_closing_transaction_amount']),
      json['channel_closing_transaction_block_height'],
      List<String>.from(
          json['channel_closing_transaction_destination_addresses']),
      'ChannelClosingTransaction',
      json['channel_closing_transaction_resolved_at'],
      json['channel_closing_transaction_transaction_hash'],
      (json['channel_closing_transaction_fees'] != null
          ? CurrencyAmount.fromJson(json['channel_closing_transaction_fees'])
          : null),
      json['channel_closing_transaction_block_hash'],
      json['channel_closing_transaction_num_confirmations'],
    );
  }

  static const fragment = r'''
fragment ChannelClosingTransactionFragment on ChannelClosingTransaction {
    __typename
    channel_closing_transaction_id: id
    channel_closing_transaction_created_at: created_at
    channel_closing_transaction_updated_at: updated_at
    channel_closing_transaction_status: status
    channel_closing_transaction_resolved_at: resolved_at
    channel_closing_transaction_amount: amount {
        __typename
        currency_amount_original_value: original_value
        currency_amount_original_unit: original_unit
        currency_amount_preferred_currency_unit: preferred_currency_unit
        currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
        currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
    }
    channel_closing_transaction_transaction_hash: transaction_hash
    channel_closing_transaction_fees: fees {
        __typename
        currency_amount_original_value: original_value
        currency_amount_original_unit: original_unit
        currency_amount_preferred_currency_unit: preferred_currency_unit
        currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
        currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
    }
    channel_closing_transaction_block_hash: block_hash
    channel_closing_transaction_block_height: block_height
    channel_closing_transaction_destination_addresses: destination_addresses
    channel_closing_transaction_num_confirmations: num_confirmations
}''';
}
