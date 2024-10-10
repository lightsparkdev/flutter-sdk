// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './currency_amount.dart';

/// This object represents the estimated L1 transaction fees for the Bitcoin network. Fee estimates are separated by potential confirmation speeds for settlement.
class FeeEstimate {
  final CurrencyAmount feeFast;

  final CurrencyAmount feeMin;

  FeeEstimate(
    this.feeFast,
    this.feeMin,
  );

  static FeeEstimate fromJson(Map<String, dynamic> json) {
    return FeeEstimate(
      CurrencyAmount.fromJson(json['fee_estimate_fee_fast']),
      CurrencyAmount.fromJson(json['fee_estimate_fee_min']),
    );
  }

  static const fragment = r'''
fragment FeeEstimateFragment on FeeEstimate {
    __typename
    fee_estimate_fee_fast: fee_fast {
        __typename
        currency_amount_original_value: original_value
        currency_amount_original_unit: original_unit
        currency_amount_preferred_currency_unit: preferred_currency_unit
        currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
        currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
    }
    fee_estimate_fee_min: fee_min {
        __typename
        currency_amount_original_value: original_value
        currency_amount_original_unit: original_unit
        currency_amount_preferred_currency_unit: preferred_currency_unit
        currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
        currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
    }
}''';
}
