// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import '../objects/initialize_wallet_output.dart';

const InitializeWallet = '''
  mutation InitializeWallet(\$key_type: KeyType!, \$signing_public_key: String!) {
    initialize_wallet(input: {
        signing_public_key: { type: \$key_type, public_key: \$signing_public_key }
    }) {
        ...InitializeWalletOutputFragment
    }
  }

  ${InitializeWalletOutput.fragment}
''';
