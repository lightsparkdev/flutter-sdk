// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import '../requester/query.dart';
import './currency_amount.dart';
import './entity.dart';
import './on_chain_transaction.dart';
import './transaction.dart';
import './transaction_status.dart';

/// This is an object representing a transaction which opens a channel on the Lightning Network. This object occurs only for channels funded by the local Lightspark node.
class ChannelOpeningTransaction
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

  ChannelOpeningTransaction(
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

  static Query<ChannelOpeningTransaction> getChannelOpeningTransactionQuery(
      String id) {
    return Query(
      '''
query GetChannelOpeningTransaction(\$id: ID!) {
    entity(id: \$id) {
        ... on ChannelOpeningTransaction {
            ...ChannelOpeningTransactionFragment
        }
    }
}

$fragment  
''',
      (json) => ChannelOpeningTransaction.fromJson(json['entity']),
      variables: {'id': id},
    );
  }

  static ChannelOpeningTransaction fromJson(Map<String, dynamic> json) {
    return ChannelOpeningTransaction(
      json['channel_opening_transaction_id'],
      json['channel_opening_transaction_created_at'],
      json['channel_opening_transaction_updated_at'],
      TransactionStatus.values
              .asNameMap()[json['channel_opening_transaction_status']] ??
          TransactionStatus.FUTURE_VALUE,
      CurrencyAmount.fromJson(json['channel_opening_transaction_amount']),
      json['channel_opening_transaction_block_height'],
      List<String>.from(
          json['channel_opening_transaction_destination_addresses']),
      'ChannelOpeningTransaction',
      json['channel_opening_transaction_resolved_at'],
      json['channel_opening_transaction_transaction_hash'],
      (json['channel_opening_transaction_fees'] != null
          ? CurrencyAmount.fromJson(json['channel_opening_transaction_fees'])
          : null),
      json['channel_opening_transaction_block_hash'],
      json['channel_opening_transaction_num_confirmations'],
    );
  }

  static const fragment = r'''
fragment ChannelOpeningTransactionFragment on ChannelOpeningTransaction {
    __typename
    channel_opening_transaction_id: id
    channel_opening_transaction_created_at: created_at
    channel_opening_transaction_updated_at: updated_at
    channel_opening_transaction_status: status
    channel_opening_transaction_resolved_at: resolved_at
    channel_opening_transaction_amount: amount {
        __typename
        currency_amount_original_value: original_value
        currency_amount_original_unit: original_unit
        currency_amount_preferred_currency_unit: preferred_currency_unit
        currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
        currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
    }
    channel_opening_transaction_transaction_hash: transaction_hash
    channel_opening_transaction_fees: fees {
        __typename
        currency_amount_original_value: original_value
        currency_amount_original_unit: original_unit
        currency_amount_preferred_currency_unit: preferred_currency_unit
        currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
        currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
    }
    channel_opening_transaction_block_hash: block_hash
    channel_opening_transaction_block_height: block_height
    channel_opening_transaction_destination_addresses: destination_addresses
    channel_opening_transaction_num_confirmations: num_confirmations
}''';
}
