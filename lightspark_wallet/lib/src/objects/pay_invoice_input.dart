// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

class PayInvoiceInput {
  /// The invoice you want to pay (as defined by the BOLT11 standard).
  final String encodedInvoice;

  /// The timeout in seconds that we will try to make the payment.
  final int timeoutSecs;

  /// The maximum amount of fees that you want to pay for this payment to be sent, expressed in msats.
  final int maximumFeesMsats;

  /// The amount you will pay for this invoice, expressed in msats. It should ONLY be set when the invoice amount is zero.
  final int? amountMsats;

  PayInvoiceInput(
    this.encodedInvoice,
    this.timeoutSecs,
    this.maximumFeesMsats,
    this.amountMsats,
  );

  static PayInvoiceInput fromJson(Map<String, dynamic> json) {
    return PayInvoiceInput(
      json['pay_invoice_input_encoded_invoice'],
      json['pay_invoice_input_timeout_secs'],
      json['pay_invoice_input_maximum_fees_msats'],
      json['pay_invoice_input_amount_msats'],
    );
  }
}
