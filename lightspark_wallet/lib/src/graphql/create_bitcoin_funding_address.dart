// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

const createBitcoinFundingAddressQuery = '''
  mutation CreateBitcoinFundingAddress {
    create_bitcoin_funding_address {
        bitcoin_address
    }
  }
''';
