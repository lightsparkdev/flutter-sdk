// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './wallet.dart';

class LoginWithJWTOutput {
  final String accessToken;

  final Wallet wallet;

  final String validUntil;

  LoginWithJWTOutput(
    this.accessToken,
    this.wallet,
    this.validUntil,
  );

  static LoginWithJWTOutput fromJson(Map<String, dynamic> json) {
    return LoginWithJWTOutput(
      json['login_with_j_w_t_output_access_token'],
      Wallet.fromJson(json['login_with_j_w_t_output_wallet']),
      json['login_with_j_w_t_output_valid_until'],
    );
  }

  static const fragment = r'''
fragment LoginWithJWTOutputFragment on LoginWithJWTOutput {
    __typename
    login_with_j_w_t_output_access_token: access_token
    login_with_j_w_t_output_wallet: wallet {
        __typename
        wallet_id: id
        wallet_created_at: created_at
        wallet_updated_at: updated_at
        wallet_balances: balances {
            __typename
            balances_owned_balance: owned_balance {
                __typename
                currency_amount_original_value: original_value
                currency_amount_original_unit: original_unit
                currency_amount_preferred_currency_unit: preferred_currency_unit
                currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
                currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
            }
            balances_available_to_send_balance: available_to_send_balance {
                __typename
                currency_amount_original_value: original_value
                currency_amount_original_unit: original_unit
                currency_amount_preferred_currency_unit: preferred_currency_unit
                currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
                currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
            }
            balances_available_to_withdraw_balance: available_to_withdraw_balance {
                __typename
                currency_amount_original_value: original_value
                currency_amount_original_unit: original_unit
                currency_amount_preferred_currency_unit: preferred_currency_unit
                currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
                currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
            }
        }
        wallet_status: status
    }
    login_with_j_w_t_output_valid_until: valid_until
}''';
}
