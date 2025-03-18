
// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved


import './invoice_type.dart';


class CreateTestModeInvoiceInputWallet {

    final int amountMsats;

    final String? memo;

    final InvoiceType? invoiceType;


    CreateTestModeInvoiceInputWallet(
        this.amountMsats, this.memo, this.invoiceType, 
    );



static CreateTestModeInvoiceInputWallet fromJson(Map<String, dynamic> json) {
    return CreateTestModeInvoiceInputWallet(
        json["create_test_mode_invoice_input_wallet_amount_msats"],
        json["create_test_mode_invoice_input_wallet_memo"],
        (json['create_test_mode_invoice_input_wallet_invoice_type'] != null) ? InvoiceType.values.asNameMap()[json['create_test_mode_invoice_input_wallet_invoice_type']] ?? InvoiceType.FUTURE_VALUE : null,

        );

}

}
