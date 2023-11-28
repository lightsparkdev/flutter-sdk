// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import '../objects/invoice.dart';

const cancelInvoiceMutation = '''
  mutation CancelInvoice(
    \$invoiceId: ID!
  ) {
    cancel_invoice(input: { invoice_id: \$invoiceId }) {
      invoice {
        ...InvoiceFragment
      }
    }
  }
  
  ${Invoice.fragment}
''';
