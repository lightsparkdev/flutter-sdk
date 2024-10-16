// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './transaction.dart';
import './entity.dart';
import '../requester/query.dart';
import './incoming_payment.dart';
import './currency_amount.dart';
import './transaction_status.dart';
import './rich_text.dart';
import './payment_request_data.dart';
import './payment_failure_reason.dart';
import '../lightspark_exception.dart';
import './outgoing_payment.dart';

/// This is an object representing a transaction made over the Lightning Network. You can retrieve this object to receive information about a specific transaction made over Lightning for a Lightspark node.
class LightningTransaction implements Transaction, Entity {
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

  /// The typename of the object
  @override
  final String typename;

  /// The date and time when this transaction was completed or failed.
  @override
  final String? resolvedAt;

  /// The hash of this transaction, so it can be uniquely identified on the Lightning Network.
  @override
  final String? transactionHash;

  LightningTransaction(
    this.id,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.amount,
    this.typename,
    this.resolvedAt,
    this.transactionHash,
  );

  static Query<LightningTransaction> getLightningTransactionQuery(String id) {
    return Query(
      '''
query GetLightningTransaction(\$id: ID!) {
    entity(id: \$id) {
        ... on LightningTransaction {
            ...LightningTransactionFragment
        }
    }
}

$fragment  
''',
      (json) => LightningTransaction.fromJson(json['entity']),
      variables: {'id': id},
    );
  }

  static LightningTransaction fromJson(Map<String, dynamic> json) {
    if (json['__typename'] == 'IncomingPayment') {
      return IncomingPayment(
        json['incoming_payment_id'],
        json['incoming_payment_created_at'],
        json['incoming_payment_updated_at'],
        TransactionStatus.values.asNameMap()[json['incoming_payment_status']] ??
            TransactionStatus.FUTURE_VALUE,
        CurrencyAmount.fromJson(json['incoming_payment_amount']),
        'IncomingPayment',
        json['incoming_payment_resolved_at'],
        json['incoming_payment_transaction_hash'],
        json['incoming_payment_payment_request']?['id'],
      );
    }
    if (json['__typename'] == 'OutgoingPayment') {
      return OutgoingPayment(
        json['outgoing_payment_id'],
        json['outgoing_payment_created_at'],
        json['outgoing_payment_updated_at'],
        TransactionStatus.values.asNameMap()[json['outgoing_payment_status']] ??
            TransactionStatus.FUTURE_VALUE,
        CurrencyAmount.fromJson(json['outgoing_payment_amount']),
        'OutgoingPayment',
        json['outgoing_payment_resolved_at'],
        json['outgoing_payment_transaction_hash'],
        (json['outgoing_payment_fees'] != null
            ? CurrencyAmount.fromJson(json['outgoing_payment_fees'])
            : null),
        (json['outgoing_payment_payment_request_data'] != null
            ? PaymentRequestData.fromJson(
                json['outgoing_payment_payment_request_data'])
            : null),
        (json['outgoing_payment_failure_reason'] != null)
            ? PaymentFailureReason.values
                    .asNameMap()[json['outgoing_payment_failure_reason']] ??
                PaymentFailureReason.FUTURE_VALUE
            : null,
        (json['outgoing_payment_failure_message'] != null
            ? RichText.fromJson(json['outgoing_payment_failure_message'])
            : null),
        json['outgoing_payment_payment_preimage'],
      );
    }
    throw LightsparkException('DeserializationError',
        'Couldn\'t find a concrete type for interface LightningTransaction corresponding to the typename=${json['__typename']}');
  }

  static const fragment = r'''
fragment LightningTransactionFragment on LightningTransaction {
    __typename
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
        outgoing_payment_payment_preimage: payment_preimage
    }
}''';
}
