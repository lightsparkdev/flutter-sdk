
// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved





class CreateTestModeInvoiceOutput {

    final String encodedPaymentRequest;


    CreateTestModeInvoiceOutput(
        this.encodedPaymentRequest, 
    );



static CreateTestModeInvoiceOutput fromJson(Map<String, dynamic> json) {
    return CreateTestModeInvoiceOutput(
        json["create_test_mode_invoice_output_encoded_payment_request"],

        );

}

    static const fragment = r'''
fragment CreateTestModeInvoiceOutputFragment on CreateTestModeInvoiceOutput {
    __typename
    create_test_mode_invoice_output_encoded_payment_request: encoded_payment_request
}''';

}
