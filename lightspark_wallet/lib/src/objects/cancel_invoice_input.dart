// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

class CancelInvoiceInput {
  final String invoiceId;

  CancelInvoiceInput(
    this.invoiceId,
  );

  static CancelInvoiceInput fromJson(Map<String, dynamic> json) {
    return CancelInvoiceInput(
      json['cancel_invoice_input_invoice_id'],
    );
  }
}
