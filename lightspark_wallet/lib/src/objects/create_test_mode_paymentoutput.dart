// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

/// This is an object identifying the output of a test mode payment. This object can be used to retrieve the associated payment made from a Test Mode Payment call.
class CreateTestModePaymentoutput {
  /// The payment that has been sent.
  /// @deprecated Use incoming_payment instead.
  final String paymentId;

  /// The payment that has been received.
  final String incomingPaymentId;

  CreateTestModePaymentoutput(
    this.paymentId,
    this.incomingPaymentId,
  );

  static CreateTestModePaymentoutput fromJson(Map<String, dynamic> json) {
    return CreateTestModePaymentoutput(
      json["create_test_mode_paymentoutput_payment"]?["id"],
      json["create_test_mode_paymentoutput_incoming_payment"]?["id"],
    );
  }

  static const fragment = r'''
fragment CreateTestModePaymentoutputFragment on CreateTestModePaymentoutput {
    __typename
    create_test_mode_paymentoutput_payment: payment {
        id
    }
    create_test_mode_paymentoutput_incoming_payment: incoming_payment {
        id
    }
}''';
}
