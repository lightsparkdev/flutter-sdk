// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

class CreateTestModePaymentInputWallet {
  /// The invoice you want to be paid (as defined by the BOLT11 standard).
  final String encodedInvoice;

  /// The amount you will be paid for this invoice, expressed in msats. It should ONLY be set when the invoice amount is
  /// zero.
  final int? amountMsats;

  CreateTestModePaymentInputWallet(
    this.encodedInvoice,
    this.amountMsats,
  );

  static CreateTestModePaymentInputWallet fromJson(Map<String, dynamic> json) {
    return CreateTestModePaymentInputWallet(
      json['create_test_mode_payment_input_wallet_encoded_invoice'],
      json['create_test_mode_payment_input_wallet_amount_msats'],
    );
  }
}
