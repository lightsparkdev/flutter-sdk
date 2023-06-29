// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './entity.dart';
import './payment_request_data.dart';
import './channel_closing_transaction.dart';
import './payment_failure_reason.dart';
import './incoming_payment.dart';
import './currency_amount.dart';
import './transaction_status.dart';
import './outgoing_payment.dart';
import './deposit.dart';
import './rich_text.dart';
import '../lightspark_exception.dart';
import './withdrawal.dart';
import './channel_opening_transaction.dart';
import '../requester/query.dart';

class Transaction implements Entity {
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
  final TransactionStatus status;

  /// The amount of money involved in this transaction.
  final CurrencyAmount amount;

  /// The typename of the object
  @override
  final String typename;

  /// The date and time when this transaction was completed or failed.
  final String? resolvedAt;

  /// The hash of this transaction, so it can be uniquely identified on the Lightning Network.
  final String? transactionHash;

  Transaction(
    this.id,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.amount,
    this.typename,
    this.resolvedAt,
    this.transactionHash,
  );

  static Query<Transaction> getTransactionQuery(String id) {
    return Query(
      '''
query GetTransaction(\$id: ID!) {
    entity(id: \$id) {
        ... on Transaction {
            ...TransactionFragment
        }
    }
}

$fragment  
''',
      (json) => Transaction.fromJson(json["entity"]),
      variables: {'id': id},
    );
  }

  static Transaction fromJson(Map<String, dynamic> json) {
    if (json["__typename"] == "ChannelClosingTransaction") {
      return ChannelClosingTransaction(
        json["channel_closing_transaction_id"],
        json["channel_closing_transaction_created_at"],
        json["channel_closing_transaction_updated_at"],
        TransactionStatus.values
                .asNameMap()[json['channel_closing_transaction_status']] ??
            TransactionStatus.FUTURE_VALUE,
        CurrencyAmount.fromJson(json["channel_closing_transaction_amount"]),
        json["channel_closing_transaction_block_height"],
        json["channel_closing_transaction_destination_addresses"],
        "ChannelClosingTransaction",
        json["channel_closing_transaction_resolved_at"],
        json["channel_closing_transaction_transaction_hash"],
        (json["channel_closing_transaction_fees"] != null
            ? CurrencyAmount.fromJson(json["channel_closing_transaction_fees"])
            : null),
        json["channel_closing_transaction_block_hash"],
        json["channel_closing_transaction_num_confirmations"],
      );
    }
    if (json["__typename"] == "ChannelOpeningTransaction") {
      return ChannelOpeningTransaction(
        json["channel_opening_transaction_id"],
        json["channel_opening_transaction_created_at"],
        json["channel_opening_transaction_updated_at"],
        TransactionStatus.values
                .asNameMap()[json['channel_opening_transaction_status']] ??
            TransactionStatus.FUTURE_VALUE,
        CurrencyAmount.fromJson(json["channel_opening_transaction_amount"]),
        json["channel_opening_transaction_block_height"],
        json["channel_opening_transaction_destination_addresses"],
        "ChannelOpeningTransaction",
        json["channel_opening_transaction_resolved_at"],
        json["channel_opening_transaction_transaction_hash"],
        (json["channel_opening_transaction_fees"] != null
            ? CurrencyAmount.fromJson(json["channel_opening_transaction_fees"])
            : null),
        json["channel_opening_transaction_block_hash"],
        json["channel_opening_transaction_num_confirmations"],
      );
    }
    if (json["__typename"] == "Deposit") {
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
    if (json["__typename"] == "IncomingPayment") {
      return IncomingPayment(
        json["incoming_payment_id"],
        json["incoming_payment_created_at"],
        json["incoming_payment_updated_at"],
        TransactionStatus.values.asNameMap()[json['incoming_payment_status']] ??
            TransactionStatus.FUTURE_VALUE,
        CurrencyAmount.fromJson(json["incoming_payment_amount"]),
        "IncomingPayment",
        json["incoming_payment_resolved_at"],
        json["incoming_payment_transaction_hash"],
        json["incoming_payment_payment_request"]?.id,
      );
    }
    if (json["__typename"] == "OutgoingPayment") {
      return OutgoingPayment(
        json["outgoing_payment_id"],
        json["outgoing_payment_created_at"],
        json["outgoing_payment_updated_at"],
        TransactionStatus.values.asNameMap()[json['outgoing_payment_status']] ??
            TransactionStatus.FUTURE_VALUE,
        CurrencyAmount.fromJson(json["outgoing_payment_amount"]),
        "OutgoingPayment",
        json["outgoing_payment_resolved_at"],
        json["outgoing_payment_transaction_hash"],
        (json["outgoing_payment_fees"] != null
            ? CurrencyAmount.fromJson(json["outgoing_payment_fees"])
            : null),
        (json["outgoing_payment_payment_request_data"] != null
            ? PaymentRequestData.fromJson(
                json["outgoing_payment_payment_request_data"])
            : null),
        (!!json["outgoing_payment_failure_reason"])
            ? PaymentFailureReason.values
                    .asNameMap()[json['outgoing_payment_failure_reason']] ??
                PaymentFailureReason.FUTURE_VALUE
            : null,
        (json["outgoing_payment_failure_message"] != null
            ? RichText.fromJson(json["outgoing_payment_failure_message"])
            : null),
      );
    }
    if (json["__typename"] == "Withdrawal") {
      return Withdrawal(
        json["withdrawal_id"],
        json["withdrawal_created_at"],
        json["withdrawal_updated_at"],
        TransactionStatus.values.asNameMap()[json['withdrawal_status']] ??
            TransactionStatus.FUTURE_VALUE,
        CurrencyAmount.fromJson(json["withdrawal_amount"]),
        json["withdrawal_block_height"],
        json["withdrawal_destination_addresses"],
        "Withdrawal",
        json["withdrawal_resolved_at"],
        json["withdrawal_transaction_hash"],
        (json["withdrawal_fees"] != null
            ? CurrencyAmount.fromJson(json["withdrawal_fees"])
            : null),
        json["withdrawal_block_hash"],
        json["withdrawal_num_confirmations"],
      );
    }
    throw LightsparkException('DeserializationError',
        'Couldn\'t find a concrete type for interface Transaction corresponding to the typename=${json['__typename']}');
  }

  static const fragment = r'''
fragment TransactionFragment on Transaction {
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
    ... on IncomingPayment {
        __typename
        incoming_payment_id: id
        incoming_payment_created_at: created_at
        incoming_payment_updated_at: updated_at
        incoming_payment_status: status
        incoming_payment_resolved_at: resolved_at
        incoming_payment_amount: amount {
            __typename
            currency_amount_original_value: original_value
            currency_amount_original_unit: original_unit
            currency_amount_preferred_currency_unit: preferred_currency_unit
            currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
            currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
        }
        incoming_payment_transaction_hash: transaction_hash
        incoming_payment_payment_request: payment_request {
            id
        }
    }
    ... on OutgoingPayment {
        __typename
        outgoing_payment_id: id
        outgoing_payment_created_at: created_at
        outgoing_payment_updated_at: updated_at
        outgoing_payment_status: status
        outgoing_payment_resolved_at: resolved_at
        outgoing_payment_amount: amount {
            __typename
            currency_amount_original_value: original_value
            currency_amount_original_unit: original_unit
            currency_amount_preferred_currency_unit: preferred_currency_unit
            currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
            currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
        }
        outgoing_payment_transaction_hash: transaction_hash
        outgoing_payment_fees: fees {
            __typename
            currency_amount_original_value: original_value
            currency_amount_original_unit: original_unit
            currency_amount_preferred_currency_unit: preferred_currency_unit
            currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
            currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
        }
        outgoing_payment_payment_request_data: payment_request_data {
            __typename
            ... on InvoiceData {
                __typename
                invoice_data_encoded_payment_request: encoded_payment_request
                invoice_data_bitcoin_network: bitcoin_network
                invoice_data_payment_hash: payment_hash
                invoice_data_amount: amount {
                    __typename
                    currency_amount_original_value: original_value
                    currency_amount_original_unit: original_unit
                    currency_amount_preferred_currency_unit: preferred_currency_unit
                    currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
                    currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
                }
                invoice_data_created_at: created_at
                invoice_data_expires_at: expires_at
                invoice_data_memo: memo
                invoice_data_destination: destination {
                    __typename
                    graph_node_id: id
                    graph_node_created_at: created_at
                    graph_node_updated_at: updated_at
                    graph_node_alias: alias
                    graph_node_bitcoin_network: bitcoin_network
                    graph_node_color: color
                    graph_node_conductivity: conductivity
                    graph_node_display_name: display_name
                    graph_node_public_key: public_key
                }
            }
        }
        outgoing_payment_failure_reason: failure_reason
        outgoing_payment_failure_message: failure_message {
            __typename
            rich_text_text: text
        }
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
