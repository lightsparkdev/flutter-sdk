
// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved


import './amazon_s3_funds_recovery_kit.dart';
import '../lightspark_exception.dart';


class FundsRecoveryKit {

    /// The bitcoin address where the funds should be sent if the recovery kit is used.
final String bitcoinWalletAddress;

    /// The typename of the object
final String typename;


    FundsRecoveryKit(
        this.bitcoinWalletAddress, this.typename, 
    );



static FundsRecoveryKit fromJson(Map<String, dynamic> json) {
    if (json["__typename"] == "AmazonS3FundsRecoveryKit") {
        return AmazonS3FundsRecoveryKit(
            json["amazon_s3_funds_recovery_kit_bitcoin_wallet_address"],
            json["amazon_s3_funds_recovery_kit_s3_bucket_url"],
"AmazonS3FundsRecoveryKit",
        );

}    throw LightsparkException('DeserializationError', 'Couldn\'t find a concrete type for interface FundsRecoveryKit corresponding to the typename=${json['__typename']}');
}

    static const fragment = r'''
fragment FundsRecoveryKitFragment on FundsRecoveryKit {
    __typename
    ... on AmazonS3FundsRecoveryKit {
        __typename
        amazon_s3_funds_recovery_kit_bitcoin_wallet_address: bitcoin_wallet_address
        amazon_s3_funds_recovery_kit_s3_bucket_url: s3_bucket_url
    }
}''';

}
