// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import "../objects/withdrawal_request.dart";

const RequestWithdrawalMutation = '''
  mutation RequestWithdrawal(
    \$amount_sats: Long!
    \$bitcoin_address: String!
  ) {
    request_withdrawal(input: {
        amount_sats: $amount_sats
        bitcoin_address: $bitcoin_address
    }) {
        request {
            ...WithdrawalRequestFragment
        }
    }
  }

  ${WithdrawalRequest.fragment}
''';
