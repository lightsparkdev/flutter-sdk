
// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved


import './currency_amount.dart';


class WithdrawalFeeEstimateOutput {

    /// The estimated fee for the withdrawal.
final CurrencyAmount feeEstimate;


    WithdrawalFeeEstimateOutput(
        this.feeEstimate, 
    );



static WithdrawalFeeEstimateOutput fromJson(Map<String, dynamic> json) {
    return WithdrawalFeeEstimateOutput(
        CurrencyAmount.fromJson(json["withdrawal_fee_estimate_output_fee_estimate"]),

        );

}

    static const fragment = r'''
fragment WithdrawalFeeEstimateOutputFragment on WithdrawalFeeEstimateOutput {
    __typename
    withdrawal_fee_estimate_output_fee_estimate: fee_estimate {
        __typename
        currency_amount_original_value: original_value
        currency_amount_original_unit: original_unit
        currency_amount_preferred_currency_unit: preferred_currency_unit
        currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
        currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
    }
}''';

}
