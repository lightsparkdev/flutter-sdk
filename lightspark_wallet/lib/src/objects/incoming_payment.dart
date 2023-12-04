// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './lightning_transaction.dart';
import './transaction.dart';
import './entity.dart';
import '../requester/query.dart';
import './currency_amount.dart';
import './transaction_status.dart';

/// This object represents any payment sent to a Lightspark node on the Lightning Network. You can retrieve this object to receive payment related information about a specific payment received by a Lightspark node.
class IncomingPayment implements LightningTransaction, Transaction, Entity {
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

  /// The optional payment request for this incoming payment, which will be null if the payment is sent through keysend.
  final String? paymentRequestId;

  IncomingPayment(
    this.id,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.amount,
    this.typename,
    this.resolvedAt,
    this.transactionHash,
    this.paymentRequestId,
  );

  static Query<IncomingPayment> getIncomingPaymentQuery(String id) {
    return Query(
      '''
query GetIncomingPayment(\$id: ID!) {
    entity(id: \$id) {
        ... on IncomingPayment {
            ...IncomingPaymentFragment
        }
    }
}

$fragment  
''',
      (json) => IncomingPayment.fromJson(json['entity']),
      variables: {'id': id},
    );
  }

  static IncomingPayment fromJson(Map<String, dynamic> json) {
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

  static const fragment = r'''
fragment IncomingPaymentFragment on IncomingPayment {
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
}''';
}
