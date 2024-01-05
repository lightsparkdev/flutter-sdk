// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './withdrawal_mode.dart';

class WithdrawalFeeEstimateInput {
  /// The amount you want to withdraw from this node in Satoshis. Use the special value -1 to withdrawal all funds from this
  /// node.
  final int amountSats;

  /// The strategy that should be used to withdraw the funds from this node.
  final WithdrawalMode withdrawalMode;

  WithdrawalFeeEstimateInput(
    this.amountSats,
    this.withdrawalMode,
  );

  static WithdrawalFeeEstimateInput fromJson(Map<String, dynamic> json) {
    return WithdrawalFeeEstimateInput(
      json['withdrawal_fee_estimate_input_amount_sats'],
      WithdrawalMode.values.asNameMap()[
              json['withdrawal_fee_estimate_input_withdrawal_mode']] ??
          WithdrawalMode.FUTURE_VALUE,
    );
  }
}
