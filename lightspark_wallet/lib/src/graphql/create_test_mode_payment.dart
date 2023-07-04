// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import  '../objects/outgoing_payment.dart';

const CreateTestModePayment = '''
mutation CreateTestModePayment(
  \$encoded_invoice: String!
  \$amount_msats: Long
) {
  create_test_mode_payment(input: {
      encoded_invoice: \$encoded_invoice
      amount_msats: \$amount_msats
  }) {
      payment {
          ...OutgoingPaymentFragment
      }
  }
}

${OutgoingPayment.fragment}
''';
