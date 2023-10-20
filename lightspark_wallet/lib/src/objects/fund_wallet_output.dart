// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './currency_amount.dart';

class FundWalletOutput {
  final CurrencyAmount amount;

  FundWalletOutput(
    this.amount,
  );

  static FundWalletOutput fromJson(Map<String, dynamic> json) {
    return FundWalletOutput(
      CurrencyAmount.fromJson(json["fund_wallet_output_amount"]),
    );
  }

  static const fragment = r'''
fragment FundWalletOutputFragment on FundWalletOutput {
    __typename
    fund_wallet_output_amount: amount {
        __typename
        currency_amount_original_value: original_value
        currency_amount_original_unit: original_unit
        currency_amount_preferred_currency_unit: preferred_currency_unit
        currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
        currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
    }
}''';
}
