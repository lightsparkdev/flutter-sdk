
// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './lightning_transaction.dart';
import './transaction.dart';
import './entity.dart';
import './currency_amount.dart';
import './payment_failure_reason.dart';
import './payment_request_data.dart';
import './transaction_status.dart';
import '../requester/query.dart';
import './rich_text.dart';

/// This object represents a Lightning Network payment sent from a Lightspark Node. You can retrieve this object to receive payment related information about any payment sent from your Lightspark Node on the Lightning Network.
class OutgoingPayment implements LightningTransaction, Transaction, Entity {

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

    /// The fees paid by the sender node to send the payment.
final CurrencyAmount? fees;

    /// The data of the payment request that was paid by this transaction, if known.
final PaymentRequestData? paymentRequestData;

    /// If applicable, the reason why the payment failed.
final PaymentFailureReason? failureReason;

    /// If applicable, user-facing error message describing why the payment failed.
final RichText? failureMessage;

    /// The preimage of the payment.
final String? paymentPreimage;


    OutgoingPayment(
        this.id, this.createdAt, this.updatedAt, this.status, this.amount, this.typename, this.resolvedAt, this.transactionHash, this.fees, this.paymentRequestData, this.failureReason, this.failureMessage, this.paymentPreimage, 
    );



    static Query<OutgoingPayment> getOutgoingPaymentQuery(String id) {
        return Query(
            '''
query GetOutgoingPayment(\$id: ID!) {
    entity(id: \$id) {
        ... on OutgoingPayment {
            ...OutgoingPaymentFragment
        }
    }
}

$fragment  
''',
            (json) => OutgoingPayment.fromJson(json["entity"]),
            variables: {'id': id},
        );
    }

static OutgoingPayment fromJson(Map<String, dynamic> json) {
    return OutgoingPayment(
        json["outgoing_payment_id"],
        json["outgoing_payment_created_at"],
        json["outgoing_payment_updated_at"],
        TransactionStatus.values.asNameMap()[json['outgoing_payment_status']] ?? TransactionStatus.FUTURE_VALUE,
        CurrencyAmount.fromJson(json["outgoing_payment_amount"]),
"OutgoingPayment",        json["outgoing_payment_resolved_at"],
        json["outgoing_payment_transaction_hash"],
        (json['outgoing_payment_fees'] != null ? CurrencyAmount.fromJson(json['outgoing_payment_fees']) : null),
        (json['outgoing_payment_payment_request_data'] != null ? PaymentRequestData.fromJson(json['outgoing_payment_payment_request_data']) : null),
        (json['outgoing_payment_failure_reason'] != null) ? PaymentFailureReason.values.asNameMap()[json['outgoing_payment_failure_reason']] ?? PaymentFailureReason.FUTURE_VALUE : null,
        (json['outgoing_payment_failure_message'] != null ? RichText.fromJson(json['outgoing_payment_failure_message']) : null),
        json["outgoing_payment_payment_preimage"],

        );

}

    static const fragment = r'''
fragment OutgoingPaymentFragment on OutgoingPayment {
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
}''';

}
