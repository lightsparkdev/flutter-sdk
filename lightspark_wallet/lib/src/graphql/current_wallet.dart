// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import "../objects/wallet.dart";

const CurrentWalletQuery = '''
query CurrentWallet {
    current_wallet {
        ...WalletFragment
    }
}

${Wallet.fragment}
''';
