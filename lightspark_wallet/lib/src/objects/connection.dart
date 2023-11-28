// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import '../lightspark_exception.dart';
import './payment_request.dart';
import './wallet_to_payment_requests_connection.dart';
import './page_info.dart';
import './transaction.dart';
import './wallet_to_transactions_connection.dart';

class Connection {
  /// The total count of objects in this connection, using the current filters. It is different from the number of objects
  /// returned in the current page (in the `entities` field).
  final int count;

  /// An object that holds pagination information about the objects in this connection.
  final PageInfo pageInfo;

  /// The typename of the object
  final String typename;

  Connection(
    this.count,
    this.pageInfo,
    this.typename,
  );

  static Connection fromJson(Map<String, dynamic> json) {
    if (json['__typename'] == 'WalletToPaymentRequestsConnection') {
      return WalletToPaymentRequestsConnection(
        json['wallet_to_payment_requests_connection_count'],
        PageInfo.fromJson(
            json['wallet_to_payment_requests_connection_page_info']),
        json['wallet_to_payment_requests_connection_entities']
            .map<PaymentRequest>((e) => PaymentRequest.fromJson(e))
            .toList(),
        'WalletToPaymentRequestsConnection',
      );
    }
    if (json['__typename'] == 'WalletToTransactionsConnection') {
      return WalletToTransactionsConnection(
        json['wallet_to_transactions_connection_count'],
        PageInfo.fromJson(json['wallet_to_transactions_connection_page_info']),
        json['wallet_to_transactions_connection_entities']
            .map<Transaction>((e) => Transaction.fromJson(e))
            .toList(),
        'WalletToTransactionsConnection',
      );
    }
    throw LightsparkException('DeserializationError',
        'Couldn\'t find a concrete type for interface Connection corresponding to the typename=${json['__typename']}');
  }

  static const fragment = r'''
fragment ConnectionFragment on Connection {
    __typename
    ... on WalletToPaymentRequestsConnection {
        __typename
        wallet_to_payment_requests_connection_count: count
        wallet_to_payment_requests_connection_page_info: page_info {
            __typename
            page_info_has_next_page: has_next_page
            page_info_has_previous_page: has_previous_page
            page_info_start_cursor: start_cursor
            page_info_end_cursor: end_cursor
        }
        wallet_to_payment_requests_connection_entities: entities {
            id
        }
    }
    ... on WalletToTransactionsConnection {
        __typename
        wallet_to_transactions_connection_count: count
        wallet_to_transactions_connection_page_info: page_info {
            __typename
            page_info_has_next_page: has_next_page
            page_info_has_previous_page: has_previous_page
            page_info_start_cursor: start_cursor
            page_info_end_cursor: end_cursor
        }
        wallet_to_transactions_connection_entities: entities {
            id
        }
    }
}''';
}
