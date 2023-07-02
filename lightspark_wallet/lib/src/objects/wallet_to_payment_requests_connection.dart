// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './page_info.dart';
import './payment_request.dart';

class WalletToPaymentRequestsConnection {
  /// An object that holds pagination information about the objects in this connection.
  final PageInfo pageInfo;

  /// The total count of objects in this connection, using the current filters. It is different from the number of objects
  /// returned in the current page (in the `entities` field).
  final int count;

  /// The payment requests for the current page of this connection.
  final List<PaymentRequest> entities;

  WalletToPaymentRequestsConnection(
    this.pageInfo,
    this.count,
    this.entities,
  );

  static WalletToPaymentRequestsConnection fromJson(Map<String, dynamic> json) {
    return WalletToPaymentRequestsConnection(
      PageInfo.fromJson(
          json["wallet_to_payment_requests_connection_page_info"]),
      json["wallet_to_payment_requests_connection_count"],
      json["wallet_to_payment_requests_connection_entities"]
          .map<PaymentRequest>((e) => PaymentRequest.fromJson(e))
          .toList(),
    );
  }

  static const fragment = r'''
fragment WalletToPaymentRequestsConnectionFragment on WalletToPaymentRequestsConnection {
    __typename
    wallet_to_payment_requests_connection_page_info: page_info {
        __typename
        page_info_has_next_page: has_next_page
        page_info_has_previous_page: has_previous_page
        page_info_start_cursor: start_cursor
        page_info_end_cursor: end_cursor
    }
    wallet_to_payment_requests_connection_count: count
    wallet_to_payment_requests_connection_entities: entities {
        id
    }
}''';
}
