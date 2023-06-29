// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './payment_request.dart';
import './entity.dart';
import './currency_amount.dart';
import './invoice_data.dart';
import './payment_request_status.dart';
import '../requester/query.dart';

/// This object represents a BOLT #11 invoice (https://github.com/lightning/bolts/blob/master/11-payment-encoding.md) initiated by a Lightspark Node.
class Invoice implements PaymentRequest, Entity {
  /// The unique identifier of this entity across all Lightspark systems. Should be treated as an opaque string.
  @override
  final String id;

  /// The date and time when the entity was first created.
  @override
  final String createdAt;

  /// The date and time when the entity was last updated.
  @override
  final String updatedAt;

  /// The details of the invoice.
  @override
  final InvoiceData data;

  /// The status of the payment request.
  @override
  final PaymentRequestStatus status;

  /// The typename of the object
  @override
  final String typename;

  /// The total amount that has been paid to this invoice.
  final CurrencyAmount? amountPaid;

  Invoice(
    this.id,
    this.createdAt,
    this.updatedAt,
    this.data,
    this.status,
    this.typename,
    this.amountPaid,
  );

  static Query<Invoice> getInvoiceQuery(String id) {
    return Query(
      '''
query GetInvoice(\$id: ID!) {
    entity(id: \$id) {
        ... on Invoice {
            ...InvoiceFragment
        }
    }
}

$fragment  
''',
      (json) => Invoice.fromJson(json["entity"]),
      variables: {'id': id},
    );
  }

  static Invoice fromJson(Map<String, dynamic> json) {
    return Invoice(
      json["invoice_id"],
      json["invoice_created_at"],
      json["invoice_updated_at"],
      InvoiceData.fromJson(json["invoice_data"]),
      PaymentRequestStatus.values.asNameMap()[json['invoice_status']] ??
          PaymentRequestStatus.FUTURE_VALUE,
      "Invoice",
      (json["invoice_amount_paid"] != null
          ? CurrencyAmount.fromJson(json["invoice_amount_paid"])
          : null),
    );
  }

  static const fragment = r'''
fragment InvoiceFragment on Invoice {
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
}''';
}
