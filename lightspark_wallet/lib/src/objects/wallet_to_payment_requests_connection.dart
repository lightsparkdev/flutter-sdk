
// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './connection.dart';
import './payment_request.dart';
import './page_info.dart';


class WalletToPaymentRequestsConnection implements Connection {

    /// The total count of objects in this connection, using the current filters. It is different from the number of objects
/// returned in the current page (in the `entities` field).
@override
final int count;

    /// An object that holds pagination information about the objects in this connection.
@override
final PageInfo pageInfo;

    /// The payment requests for the current page of this connection.
final List<PaymentRequest> entities;

    /// The typename of the object
@override
final String typename;


    WalletToPaymentRequestsConnection(
        this.count, this.pageInfo, this.entities, this.typename, 
    );



static WalletToPaymentRequestsConnection fromJson(Map<String, dynamic> json) {
    return WalletToPaymentRequestsConnection(
        json["wallet_to_payment_requests_connection_count"],
        PageInfo.fromJson(json["wallet_to_payment_requests_connection_page_info"]),
        json["wallet_to_payment_requests_connection_entities"].map<PaymentRequest>((e) => PaymentRequest.fromJson(e)).toList(),
"WalletToPaymentRequestsConnection",
        );

}

    static const fragment = r'''
fragment WalletToPaymentRequestsConnectionFragment on WalletToPaymentRequestsConnection {
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
}''';

}
