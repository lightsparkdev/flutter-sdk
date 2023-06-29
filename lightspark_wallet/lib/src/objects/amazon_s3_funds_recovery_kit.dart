// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './funds_recovery_kit.dart';

class AmazonS3FundsRecoveryKit implements FundsRecoveryKit {
  /// The bitcoin address where the funds should be sent if the recovery kit is used.
  @override
  final String bitcoinWalletAddress;

  /// The URL of the Amazon S3 bucket URL where we should upload the funds recovery kit.
  final String s3BucketUrl;

  /// The typename of the object
  @override
  final String typename;

  AmazonS3FundsRecoveryKit(
    this.bitcoinWalletAddress,
    this.s3BucketUrl,
    this.typename,
  );

  static AmazonS3FundsRecoveryKit fromJson(Map<String, dynamic> json) {
    return AmazonS3FundsRecoveryKit(
      json["amazon_s3_funds_recovery_kit_bitcoin_wallet_address"],
      json["amazon_s3_funds_recovery_kit_s3_bucket_url"],
      "AmazonS3FundsRecoveryKit",
    );
  }

  static const fragment = r'''
fragment AmazonS3FundsRecoveryKitFragment on AmazonS3FundsRecoveryKit {
    __typename
    amazon_s3_funds_recovery_kit_bitcoin_wallet_address: bitcoin_wallet_address
    amazon_s3_funds_recovery_kit_s3_bucket_url: s3_bucket_url
}''';
}
