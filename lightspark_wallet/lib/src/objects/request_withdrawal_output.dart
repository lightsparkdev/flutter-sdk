
// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved





class RequestWithdrawalOutput {

    /// The request that is created for this withdrawal.
final String requestId;


    RequestWithdrawalOutput(
        this.requestId, 
    );



static RequestWithdrawalOutput fromJson(Map<String, dynamic> json) {
    return RequestWithdrawalOutput(
        json["request_withdrawal_output_request"]?["id"],

        );

}

    static const fragment = r'''
fragment RequestWithdrawalOutputFragment on RequestWithdrawalOutput {
    __typename
    request_withdrawal_output_request: request {
        id
    }
}''';

}
