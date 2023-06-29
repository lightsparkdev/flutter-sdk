// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './on_chain_transaction.dart';
import './transaction.dart';
import './entity.dart';
import './transaction_status.dart';
import './currency_amount.dart';
import '../requester/query.dart';

/// The transaction on Bitcoin blockchain to fund the Lightspark node's wallet.
class Deposit implements OnChainTransaction, Transaction, Entity {
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

  Deposit(
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

  static Query<Deposit> getDepositQuery(String id) {
    return Query(
      '''
query GetDeposit(\$id: ID!) {
    entity(id: \$id) {
        ... on Deposit {
            ...DepositFragment
        }
    }
}

$fragment  
''',
      (json) => Deposit.fromJson(json["entity"]),
      variables: {'id': id},
    );
  }

  static Deposit fromJson(Map<String, dynamic> json) {
    return Deposit(
      json["deposit_id"],
      json["deposit_created_at"],
      json["deposit_updated_at"],
      TransactionStatus.values.asNameMap()[json['deposit_status']] ??
          TransactionStatus.FUTURE_VALUE,
      CurrencyAmount.fromJson(json["deposit_amount"]),
      json["deposit_block_height"],
      json["deposit_destination_addresses"],
      "Deposit",
      json["deposit_resolved_at"],
      json["deposit_transaction_hash"],
      (json["deposit_fees"] != null
          ? CurrencyAmount.fromJson(json["deposit_fees"])
          : null),
      json["deposit_block_hash"],
      json["deposit_num_confirmations"],
    );
  }

  static const fragment = r'''
fragment DepositFragment on Deposit {
    __typename
    deposit_id: id
    deposit_created_at: created_at
    deposit_updated_at: updated_at
    deposit_status: status
    deposit_resolved_at: resolved_at
    deposit_amount: amount {
        __typename
        currency_amount_original_value: original_value
        currency_amount_original_unit: original_unit
        currency_amount_preferred_currency_unit: preferred_currency_unit
        currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
        currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
    }
    deposit_transaction_hash: transaction_hash
    deposit_fees: fees {
        __typename
        currency_amount_original_value: original_value
        currency_amount_original_unit: original_unit
        currency_amount_preferred_currency_unit: preferred_currency_unit
        currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
        currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
    }
    deposit_block_hash: block_hash
    deposit_block_height: block_height
    deposit_destination_addresses: destination_addresses
    deposit_num_confirmations: num_confirmations
}''';
}
