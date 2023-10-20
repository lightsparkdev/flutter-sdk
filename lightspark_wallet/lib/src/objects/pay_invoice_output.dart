// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

class PayInvoiceOutput {
  /// The payment that has been sent.
  final String paymentId;

  PayInvoiceOutput(
    this.paymentId,
  );

  static PayInvoiceOutput fromJson(Map<String, dynamic> json) {
    return PayInvoiceOutput(
      json["pay_invoice_output_payment"]?["id"],
    );
  }

  static const fragment = r'''
fragment PayInvoiceOutputFragment on PayInvoiceOutput {
    __typename
    pay_invoice_output_payment: payment {
        id
    }
}''';
}
