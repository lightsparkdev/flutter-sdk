// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

class FundWalletInput {
  final int? amountSats;

  final String? fundingAddress;

  FundWalletInput(
    this.amountSats,
    this.fundingAddress,
  );

  static FundWalletInput fromJson(Map<String, dynamic> json) {
    return FundWalletInput(
      json['fund_wallet_input_amount_sats'],
      json['fund_wallet_input_funding_address'],
    );
  }
}
