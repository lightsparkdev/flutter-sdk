// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

class SendPaymentInput {
  /// The public key of the destination node.
  final String destinationPublicKey;

  /// The timeout in seconds that we will try to make the payment.
  final int timeoutSecs;

  /// The amount you will send to the destination node, expressed in msats.
  final int amountMsats;

  /// The maximum amount of fees that you want to pay for this payment to be sent, expressed in msats.
  final int maximumFeesMsats;

  SendPaymentInput(
    this.destinationPublicKey,
    this.timeoutSecs,
    this.amountMsats,
    this.maximumFeesMsats,
  );

  static SendPaymentInput fromJson(Map<String, dynamic> json) {
    return SendPaymentInput(
      json["send_payment_input_destination_public_key"],
      json["send_payment_input_timeout_secs"],
      json["send_payment_input_amount_msats"],
      json["send_payment_input_maximum_fees_msats"],
    );
  }
}
