// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

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
