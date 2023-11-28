// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

class CancelInvoiceOutput {
  final String invoiceId;

  CancelInvoiceOutput(
    this.invoiceId,
  );

  static CancelInvoiceOutput fromJson(Map<String, dynamic> json) {
    return CancelInvoiceOutput(
      json['cancel_invoice_output_invoice']?['id'],
    );
  }

  static const fragment = r'''
fragment CancelInvoiceOutputFragment on CancelInvoiceOutput {
    __typename
    cancel_invoice_output_invoice: invoice {
        id
    }
}''';
}
