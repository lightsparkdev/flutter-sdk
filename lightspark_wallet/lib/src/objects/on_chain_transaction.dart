
// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './transaction.dart';
import './entity.dart';
import './channel_opening_transaction.dart';
import './transaction_status.dart';
import './deposit.dart';
import './withdrawal.dart';
import './channel_closing_transaction.dart';
import '../lightspark_exception.dart';
import './currency_amount.dart';
import '../requester/query.dart';

/// This object represents an L1 transaction that occurred on the Bitcoin Network. You can retrieve this object to receive information about a specific on-chain transaction made on the Lightning Network associated with your Lightspark Node.
class OnChainTransaction implements Transaction, Entity {

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
final int blockHeight;

    /// The Bitcoin blockchain addresses this transaction was sent to.
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
final CurrencyAmount? fees;

    /// The hash of the block that included this transaction. This will be null for unconfirmed transactions.
final String? blockHash;

    /// The number of blockchain confirmations for this transaction in real time.
final int? numConfirmations;


    OnChainTransaction(
        this.id, this.createdAt, this.updatedAt, this.status, this.amount, this.blockHeight, this.destinationAddresses, this.typename, this.resolvedAt, this.transactionHash, this.fees, this.blockHash, this.numConfirmations, 
    );



    static Query<OnChainTransaction> getOnChainTransactionQuery(String id) {
        return Query(
            '''
query GetOnChainTransaction(\$id: ID!) {
    entity(id: \$id) {
        ... on OnChainTransaction {
            ...OnChainTransactionFragment
        }
    }
}

$fragment  
''',
            (json) => OnChainTransaction.fromJson(json["entity"]),
            variables: {'id': id},
        );
    }

static OnChainTransaction fromJson(Map<String, dynamic> json) {
    if (json["__typename"] == "ChannelClosingTransaction") {
        return ChannelClosingTransaction(
            json["channel_closing_transaction_id"],
            json["channel_closing_transaction_created_at"],
            json["channel_closing_transaction_updated_at"],
            TransactionStatus.values.asNameMap()[json['channel_closing_transaction_status']] ?? TransactionStatus.FUTURE_VALUE,
            CurrencyAmount.fromJson(json["channel_closing_transaction_amount"]),
            json["channel_closing_transaction_block_height"],
            List<String>.from(json['channel_closing_transaction_destination_addresses']),
"ChannelClosingTransaction",            json["channel_closing_transaction_resolved_at"],
            json["channel_closing_transaction_transaction_hash"],
            (json['channel_closing_transaction_fees'] != null ? CurrencyAmount.fromJson(json['channel_closing_transaction_fees']) : null),
            json["channel_closing_transaction_block_hash"],
            json["channel_closing_transaction_num_confirmations"],

        );

}    if (json["__typename"] == "ChannelOpeningTransaction") {
        return ChannelOpeningTransaction(
            json["channel_opening_transaction_id"],
            json["channel_opening_transaction_created_at"],
            json["channel_opening_transaction_updated_at"],
            TransactionStatus.values.asNameMap()[json['channel_opening_transaction_status']] ?? TransactionStatus.FUTURE_VALUE,
            CurrencyAmount.fromJson(json["channel_opening_transaction_amount"]),
            json["channel_opening_transaction_block_height"],
            List<String>.from(json['channel_opening_transaction_destination_addresses']),
"ChannelOpeningTransaction",            json["channel_opening_transaction_resolved_at"],
            json["channel_opening_transaction_transaction_hash"],
            (json['channel_opening_transaction_fees'] != null ? CurrencyAmount.fromJson(json['channel_opening_transaction_fees']) : null),
            json["channel_opening_transaction_block_hash"],
            json["channel_opening_transaction_num_confirmations"],

        );

}    if (json["__typename"] == "Deposit") {
        return Deposit(
            json["deposit_id"],
            json["deposit_created_at"],
            json["deposit_updated_at"],
            TransactionStatus.values.asNameMap()[json['deposit_status']] ?? TransactionStatus.FUTURE_VALUE,
            CurrencyAmount.fromJson(json["deposit_amount"]),
            json["deposit_block_height"],
            List<String>.from(json['deposit_destination_addresses']),
"Deposit",            json["deposit_resolved_at"],
            json["deposit_transaction_hash"],
            (json['deposit_fees'] != null ? CurrencyAmount.fromJson(json['deposit_fees']) : null),
            json["deposit_block_hash"],
            json["deposit_num_confirmations"],

        );

}    if (json["__typename"] == "Withdrawal") {
        return Withdrawal(
            json["withdrawal_id"],
            json["withdrawal_created_at"],
            json["withdrawal_updated_at"],
            TransactionStatus.values.asNameMap()[json['withdrawal_status']] ?? TransactionStatus.FUTURE_VALUE,
            CurrencyAmount.fromJson(json["withdrawal_amount"]),
            json["withdrawal_block_height"],
            List<String>.from(json['withdrawal_destination_addresses']),
"Withdrawal",            json["withdrawal_resolved_at"],
            json["withdrawal_transaction_hash"],
            (json['withdrawal_fees'] != null ? CurrencyAmount.fromJson(json['withdrawal_fees']) : null),
            json["withdrawal_block_hash"],
            json["withdrawal_num_confirmations"],

        );

}    throw LightsparkException('DeserializationError', 'Couldn\'t find a concrete type for interface OnChainTransaction corresponding to the typename=${json['__typename']}');
}

    static const fragment = r'''
fragment OnChainTransactionFragment on OnChainTransaction {
    __typename
    ... on ChannelClosingTransaction {
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
    }
    ... on ChannelOpeningTransaction {
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
    }
    ... on Deposit {
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
    }
    ... on Withdrawal {
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
    }
}''';

}
