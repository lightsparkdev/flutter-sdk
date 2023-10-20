// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './currency_amount.dart';

class LightningFeeEstimateOutput {
  /// The estimated fees for the payment.
  final CurrencyAmount feeEstimate;

  LightningFeeEstimateOutput(
    this.feeEstimate,
  );

  static LightningFeeEstimateOutput fromJson(Map<String, dynamic> json) {
    return LightningFeeEstimateOutput(
      CurrencyAmount.fromJson(
          json["lightning_fee_estimate_output_fee_estimate"]),
    );
  }

  static const fragment = r'''
fragment LightningFeeEstimateOutputFragment on LightningFeeEstimateOutput {
    __typename
    lightning_fee_estimate_output_fee_estimate: fee_estimate {
        __typename
        currency_amount_original_value: original_value
        currency_amount_original_unit: original_unit
        currency_amount_preferred_currency_unit: preferred_currency_unit
        currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
        currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
    }
}''';
}
