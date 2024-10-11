// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './invoice_type.dart';

class CreateInvoiceInput {
  final int amountMsats;

  final String? memo;

  final InvoiceType? invoiceType;

  final int? expirySecs;

  CreateInvoiceInput(
    this.amountMsats,
    this.memo,
    this.invoiceType,
    this.expirySecs,
  );

  static CreateInvoiceInput fromJson(Map<String, dynamic> json) {
    return CreateInvoiceInput(
      json['create_invoice_input_amount_msats'],
      json['create_invoice_input_memo'],
      (json['create_invoice_input_invoice_type'] != null)
          ? InvoiceType.values
                  .asNameMap()[json['create_invoice_input_invoice_type']] ??
              InvoiceType.FUTURE_VALUE
          : null,
      json['create_invoice_input_expiry_secs'],
    );
  }
}
