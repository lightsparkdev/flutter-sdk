// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

class CreateBitcoinFundingAddressOutput {
  final String bitcoinAddress;

  CreateBitcoinFundingAddressOutput(
    this.bitcoinAddress,
  );

  static CreateBitcoinFundingAddressOutput fromJson(Map<String, dynamic> json) {
    return CreateBitcoinFundingAddressOutput(
      json['create_bitcoin_funding_address_output_bitcoin_address'],
    );
  }

  static const fragment = r'''
fragment CreateBitcoinFundingAddressOutputFragment on CreateBitcoinFundingAddressOutput {
    __typename
    create_bitcoin_funding_address_output_bitcoin_address: bitcoin_address
}''';
}
