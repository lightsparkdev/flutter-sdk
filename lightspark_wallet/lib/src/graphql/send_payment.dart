// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import "../objects/outgoing_payment.dart";

const SendPaymentMutation = '''
  mutation SendPayment(
    \$destination_public_key: String!
    \$timeout_secs: Int!
    \$amount_msats: Long!
    \$maximum_fees_msats: Long!
  ) {
    send_payment(
      input: {
        destination_public_key: \$destination_public_key
        timeout_secs: \$timeout_secs
        amount_msats: \$amount_msats
        maximum_fees_msats: \$maximum_fees_msats
      }
    ) {
      payment {
        ...OutgoingPaymentFragment
      }
    }
  }

  ${OutgoingPayment.fragment}
''';
