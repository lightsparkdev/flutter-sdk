
// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved





class FundWalletInput {

    final int? amountSats;


    FundWalletInput(
        this.amountSats, 
    );



static FundWalletInput fromJson(Map<String, dynamic> json) {
    return FundWalletInput(
        json["fund_wallet_input_amount_sats"],

        );

}

}
