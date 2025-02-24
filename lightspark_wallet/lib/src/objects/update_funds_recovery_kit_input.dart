
// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved





class UpdateFundsRecoveryKitInput {

    final String s3BucketUrl;

    final String bitcoinWalletAddress;


    UpdateFundsRecoveryKitInput(
        this.s3BucketUrl, this.bitcoinWalletAddress, 
    );



static UpdateFundsRecoveryKitInput fromJson(Map<String, dynamic> json) {
    return UpdateFundsRecoveryKitInput(
        json["update_funds_recovery_kit_input_s3_bucket_url"],
        json["update_funds_recovery_kit_input_bitcoin_wallet_address"],

        );

}

}
