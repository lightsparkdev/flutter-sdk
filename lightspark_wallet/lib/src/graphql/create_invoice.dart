// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import '../objects/invoice_data.dart';

const createInvoiceMutation = '''
  mutation CreateInvoice(
    \$amountMsats: Long!
    \$memo: String
    \$type: InvoiceType = null
    ) {
    create_invoice(input: { amount_msats: \$amountMsats, memo: \$memo, invoice_type: \$type }) {
      invoice {
        data {
          ...InvoiceDataFragment
        }
      }
    }
  }
  
  ${InvoiceData.fragment}
''';
