// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import '../objects/invoice_data.dart';

const DecodeInvoiceQuery = '''
  query DecodeInvoice(\$encoded_payment_request: String!) {
    decoded_payment_request(encoded_payment_request: \$encoded_payment_request) {
      __typename
      ... on InvoiceData {
        ...InvoiceDataFragment
      }
    }
  }

${InvoiceData.fragment}
''';
