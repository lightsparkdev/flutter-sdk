// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import "../objects/terminate_wallet_output.dart";

const TerminateWallet = '''
  mutation TerminateWallet {
    terminate_wallet {
      ...TerminateWalletOutputFragment
    }
  }
  
  ${TerminateWalletOutput.fragment}
''';
