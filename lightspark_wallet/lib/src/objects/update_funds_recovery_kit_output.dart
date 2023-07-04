// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './funds_recovery_kit.dart';

class UpdateFundsRecoveryKitOutput {
  final String walletId;

  final FundsRecoveryKit fundsRecoveryKit;

  UpdateFundsRecoveryKitOutput(
    this.walletId,
    this.fundsRecoveryKit,
  );

  static UpdateFundsRecoveryKitOutput fromJson(Map<String, dynamic> json) {
    return UpdateFundsRecoveryKitOutput(
      json['update_funds_recovery_kit_output_wallet']?.id,
      FundsRecoveryKit.fromJson(
          json['update_funds_recovery_kit_output_funds_recovery_kit']),
    );
  }

  static const fragment = r'''
fragment UpdateFundsRecoveryKitOutputFragment on UpdateFundsRecoveryKitOutput {
    __typename
    update_funds_recovery_kit_output_wallet: wallet {
        id
    }
    update_funds_recovery_kit_output_funds_recovery_kit: funds_recovery_kit {
        __typename
        ... on AmazonS3FundsRecoveryKit {
            __typename
            amazon_s3_funds_recovery_kit_bitcoin_wallet_address: bitcoin_wallet_address
            amazon_s3_funds_recovery_kit_s3_bucket_url: s3_bucket_url
        }
    }
}''';
}
