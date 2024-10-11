// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './connection.dart';
import './page_info.dart';
import './withdrawal_request.dart';

class WalletToWithdrawalRequestsConnection implements Connection {
  /// The total count of objects in this connection, using the current filters. It is different from the number of objects
  /// returned in the current page (in the `entities` field).
  @override
  final int count;

  /// An object that holds pagination information about the objects in this connection.
  @override
  final PageInfo pageInfo;

  /// The withdrawal requests for the current page of this connection.
  final List<WithdrawalRequest> entities;

  /// The typename of the object
  @override
  final String typename;

  WalletToWithdrawalRequestsConnection(
    this.count,
    this.pageInfo,
    this.entities,
    this.typename,
  );

  static WalletToWithdrawalRequestsConnection fromJson(
      Map<String, dynamic> json) {
    return WalletToWithdrawalRequestsConnection(
      json['wallet_to_withdrawal_requests_connection_count'],
      PageInfo.fromJson(
          json['wallet_to_withdrawal_requests_connection_page_info']),
      json['wallet_to_withdrawal_requests_connection_entities']
          .map<WithdrawalRequest>((e) => WithdrawalRequest.fromJson(e))
          .toList(),
      'WalletToWithdrawalRequestsConnection',
    );
  }

  static const fragment = r'''
fragment WalletToWithdrawalRequestsConnectionFragment on WalletToWithdrawalRequestsConnection {
    __typename
    wallet_to_withdrawal_requests_connection_count: count
    wallet_to_withdrawal_requests_connection_page_info: page_info {
        __typename
        page_info_has_next_page: has_next_page
        page_info_has_previous_page: has_previous_page
        page_info_start_cursor: start_cursor
        page_info_end_cursor: end_cursor
    }
    wallet_to_withdrawal_requests_connection_entities: entities {
        id
    }
}''';
}
