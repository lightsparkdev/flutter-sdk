// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

class LightningFeeEstimateForInvoiceInput {
  /// The invoice you want to pay (as defined by the BOLT11 standard).
  final String encodedPaymentRequest;

  /// If the invoice does not specify a payment amount, then the amount that you wish to pay, expressed in msats.
  final int? amountMsats;

  LightningFeeEstimateForInvoiceInput(
    this.encodedPaymentRequest,
    this.amountMsats,
  );

  static LightningFeeEstimateForInvoiceInput fromJson(
      Map<String, dynamic> json) {
    return LightningFeeEstimateForInvoiceInput(
      json["lightning_fee_estimate_for_invoice_input_encoded_payment_request"],
      json["lightning_fee_estimate_for_invoice_input_amount_msats"],
    );
  }
}
