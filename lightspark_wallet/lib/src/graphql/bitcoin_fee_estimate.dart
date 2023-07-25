// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import '../objects/fee_estimate.dart';

const bitcoinFeeEstimateQuery = '''
  query BitcoinFeeEstimate {
    bitcoin_fee_estimate {
      ...FeeEstimateFragment
    }
  }

  ${FeeEstimate.fragment}
''';
