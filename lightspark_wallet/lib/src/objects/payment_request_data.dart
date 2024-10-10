
// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved


import './currency_amount.dart';
import './graph_node.dart';
import './invoice_data.dart';
import './bitcoin_network.dart';
import '../lightspark_exception.dart';

/// This object is an interface of a payment request on the Lightning Network (i.e., a Lightning Invoice). It contains data related to parsing the payment details of a Lightning Invoice.
class PaymentRequestData {

    final String encodedPaymentRequest;

    final BitcoinNetwork bitcoinNetwork;

    /// The typename of the object
final String typename;


    PaymentRequestData(
        this.encodedPaymentRequest, this.bitcoinNetwork, this.typename, 
    );



static PaymentRequestData fromJson(Map<String, dynamic> json) {
    if (json["__typename"] == "InvoiceData") {
        return InvoiceData(
            json["invoice_data_encoded_payment_request"],
            BitcoinNetwork.values.asNameMap()[json['invoice_data_bitcoin_network']] ?? BitcoinNetwork.FUTURE_VALUE,
            json["invoice_data_payment_hash"],
            CurrencyAmount.fromJson(json["invoice_data_amount"]),
            json["invoice_data_created_at"],
            json["invoice_data_expires_at"],
            GraphNode.fromJson(json["invoice_data_destination"]),
"InvoiceData",            json["invoice_data_memo"],

        );

}    throw LightsparkException('DeserializationError', 'Couldn\'t find a concrete type for interface PaymentRequestData corresponding to the typename=${json['__typename']}');
}

    static const fragment = r'''
fragment PaymentRequestDataFragment on PaymentRequestData {
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
}''';

}
