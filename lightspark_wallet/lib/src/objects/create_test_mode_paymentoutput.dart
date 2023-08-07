// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

/// This is an object identifying the output of a test mode payment. This object can be used to retrieve the associated payment made from a Test Mode Payment call.
class CreateTestModePaymentoutput {
  /// The payment that has been sent.
  final String paymentId;

  CreateTestModePaymentoutput(
    this.paymentId,
  );

  static CreateTestModePaymentoutput fromJson(Map<String, dynamic> json) {
    return CreateTestModePaymentoutput(
      json['create_test_mode_paymentoutput_payment']?['id'],
    );
  }

  static const fragment = r'''
fragment CreateTestModePaymentoutputFragment on CreateTestModePaymentoutput {
    __typename
    create_test_mode_paymentoutput_payment: payment {
        id
    }
}''';
}
