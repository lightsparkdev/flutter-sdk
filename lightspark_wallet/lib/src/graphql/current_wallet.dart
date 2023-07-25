// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import '../objects/wallet.dart';

const currentWalletQuery = '''
query CurrentWallet {
    current_wallet {
        id
        ...WalletFragment
    }
}

${Wallet.fragment}
''';
