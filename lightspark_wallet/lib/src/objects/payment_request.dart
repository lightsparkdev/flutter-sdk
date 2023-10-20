// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './entity.dart';
import '../requester/query.dart';
import './payment_request_status.dart';
import './payment_request_data.dart';
import './invoice.dart';
import './currency_amount.dart';
import '../lightspark_exception.dart';
import './invoice_data.dart';

/// This object contains information related to a payment request generated or received by a LightsparkNode. You can retrieve this object to receive payment information about a specific invoice.
class PaymentRequest implements Entity {
  /// The unique identifier of this entity across all Lightspark systems. Should be treated as an opaque string.
  @override
  final String id;

  /// The date and time when the entity was first created.
  @override
  final String createdAt;

  /// The date and time when the entity was last updated.
  @override
  final String updatedAt;

  /// The details of the payment request.
  final PaymentRequestData data;

  /// The status of the payment request.
  final PaymentRequestStatus status;

  /// The typename of the object
  @override
  final String typename;

  PaymentRequest(
    this.id,
    this.createdAt,
    this.updatedAt,
    this.data,
    this.status,
    this.typename,
  );

  static Query<PaymentRequest> getPaymentRequestQuery(String id) {
    return Query(
      '''
query GetPaymentRequest(\$id: ID!) {
    entity(id: \$id) {
        ... on PaymentRequest {
            ...PaymentRequestFragment
        }
    }
}

$fragment  
''',
      (json) => PaymentRequest.fromJson(json['entity']),
      variables: {'id': id},
    );
  }

  static PaymentRequest fromJson(Map<String, dynamic> json) {
    if (json['__typename'] == 'Invoice') {
      return Invoice(
        json['invoice_id'],
        json['invoice_created_at'],
        json['invoice_updated_at'],
        InvoiceData.fromJson(json['invoice_data']),
        PaymentRequestStatus.values.asNameMap()[json['invoice_status']] ??
            PaymentRequestStatus.FUTURE_VALUE,
        'Invoice',
        (json['invoice_amount_paid'] != null
            ? CurrencyAmount.fromJson(json['invoice_amount_paid'])
            : null),
      );
    }
    throw LightsparkException('DeserializationError',
        'Couldn\'t find a concrete type for interface PaymentRequest corresponding to the typename=${json['__typename']}');
  }

  static const fragment = r'''
fragment PaymentRequestFragment on PaymentRequest {
    __typename
    ... on Invoice {
        __typename
        invoice_id: id
        invoice_created_at: created_at
        invoice_updated_at: updated_at
        invoice_data: data {
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
        invoice_status: status
        invoice_amount_paid: amount_paid {
            __typename
            currency_amount_original_value: original_value
            currency_amount_original_unit: original_unit
            currency_amount_preferred_currency_unit: preferred_currency_unit
            currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
            currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
        }
    }
}''';
}
