// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

/// The unique identifier of the Invoice that should be cancelled. The invoice is supposed to be open, not settled and not expired.
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
