// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

class CreateInvoiceOutput {
  final String invoiceId;

  CreateInvoiceOutput(
    this.invoiceId,
  );

  static CreateInvoiceOutput fromJson(Map<String, dynamic> json) {
    return CreateInvoiceOutput(
      json['create_invoice_output_invoice']?.id,
    );
  }

  static const fragment = r'''
fragment CreateInvoiceOutputFragment on CreateInvoiceOutput {
    __typename
    create_invoice_output_invoice: invoice {
        id
    }
}''';
}
