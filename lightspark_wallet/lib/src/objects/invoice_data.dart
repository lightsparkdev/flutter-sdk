// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './payment_request_data.dart';
import './bitcoin_network.dart';
import './currency_amount.dart';
import './graph_node.dart';

/// This object represents the BOLT #11 invoice protocol for Lightning Payments. See https://github.com/lightning/bolts/blob/master/11-payment-encoding.md.
class InvoiceData implements PaymentRequestData {
  @override
  final String encodedPaymentRequest;

  @override
  final BitcoinNetwork bitcoinNetwork;

  /// The payment hash of this invoice.
  final String paymentHash;

  /// The requested amount in this invoice. If it is equal to 0, the sender should choose the amount to send.
  final CurrencyAmount amount;

  /// The date and time when this invoice was created.
  final String createdAt;

  /// The date and time when this invoice will expire.
  final String expiresAt;

  /// The lightning node that will be paid when fulfilling this invoice.
  final GraphNode destination;

  /// The typename of the object
  @override
  final String typename;

  /// A short, UTF-8 encoded, description of the purpose of this invoice.
  final String? memo;

  InvoiceData(
    this.encodedPaymentRequest,
    this.bitcoinNetwork,
    this.paymentHash,
    this.amount,
    this.createdAt,
    this.expiresAt,
    this.destination,
    this.typename,
    this.memo,
  );

  static InvoiceData fromJson(Map<String, dynamic> json) {
    return InvoiceData(
      json["invoice_data_encoded_payment_request"],
      BitcoinNetwork.values.asNameMap()[json['invoice_data_bitcoin_network']] ??
          BitcoinNetwork.FUTURE_VALUE,
      json["invoice_data_payment_hash"],
      CurrencyAmount.fromJson(json["invoice_data_amount"]),
      json["invoice_data_created_at"],
      json["invoice_data_expires_at"],
      GraphNode.fromJson(json["invoice_data_destination"]),
      "InvoiceData",
      json["invoice_data_memo"],
    );
  }

  static const fragment = r'''
fragment InvoiceDataFragment on InvoiceData {
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
}''';
}
