
// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved





class RequestWithdrawalInput {

    /// The bitcoin address where the withdrawal should be sent.
final String bitcoinAddress;

    /// The amount you want to withdraw from this node in Satoshis. Use the special value -1 to withdrawal all funds from this
/// node.
final int amountSats;


    RequestWithdrawalInput(
        this.bitcoinAddress, this.amountSats, 
    );



static RequestWithdrawalInput fromJson(Map<String, dynamic> json) {
    return RequestWithdrawalInput(
        json["request_withdrawal_input_bitcoin_address"],
        json["request_withdrawal_input_amount_sats"],

        );

}

}
