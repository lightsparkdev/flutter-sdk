// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import '../objects/deploy_wallet_output.dart';

const deployWalletQuery = '''
  mutation DeployWallet {
    deploy_wallet {
      ...DeployWalletOutputFragment
    }
  }
  
  ${DeployWalletOutput.fragment}
''';
