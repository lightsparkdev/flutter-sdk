
// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved


import './withdrawal.dart';


class WithdrawalRequestToWithdrawalsConnection {

    /// The total count of objects in this connection, using the current filters. It is different from the number of objects
/// returned in the current page (in the `entities` field).
final int count;

    /// The withdrawals for the current page of this connection.
final List<Withdrawal> entities;


    WithdrawalRequestToWithdrawalsConnection(
        this.count, this.entities, 
    );



static WithdrawalRequestToWithdrawalsConnection fromJson(Map<String, dynamic> json) {
    return WithdrawalRequestToWithdrawalsConnection(
        json["withdrawal_request_to_withdrawals_connection_count"],
        json["withdrawal_request_to_withdrawals_connection_entities"].map<Withdrawal>((e) => Withdrawal.fromJson(e)).toList(),

        );

}

    static const fragment = r'''
fragment WithdrawalRequestToWithdrawalsConnectionFragment on WithdrawalRequestToWithdrawalsConnection {
    __typename
    withdrawal_request_to_withdrawals_connection_count: count
    withdrawal_request_to_withdrawals_connection_entities: entities {
        id
    }
}''';

}
