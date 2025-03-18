
// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved





class SendPaymentOutput {

    /// The payment that has been sent.
final String paymentId;


    SendPaymentOutput(
        this.paymentId, 
    );



static SendPaymentOutput fromJson(Map<String, dynamic> json) {
    return SendPaymentOutput(
        json["send_payment_output_payment"]?["id"],

        );

}

    static const fragment = r'''
fragment SendPaymentOutputFragment on SendPaymentOutput {
    __typename
    send_payment_output_payment: payment {
        id
    }
}''';

}
