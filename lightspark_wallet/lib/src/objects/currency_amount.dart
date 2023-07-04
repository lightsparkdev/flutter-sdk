// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './currency_unit.dart';

/// Represents the value and unit for an amount of currency.
class CurrencyAmount {
  /// The original numeric value for this CurrencyAmount.
  final int originalValue;

  /// The original unit of currency for this CurrencyAmount.
  final CurrencyUnit originalUnit;

  /// The unit of user's preferred currency.
  final CurrencyUnit preferredCurrencyUnit;

  /// The rounded numeric value for this CurrencyAmount in the very base level of user's preferred currency. For example, for
  /// USD, the value will be in cents.
  final int preferredCurrencyValueRounded;

  /// The approximate float value for this CurrencyAmount in the very base level of user's preferred currency. For example,
  /// for USD, the value will be in cents.
  final double preferredCurrencyValueApprox;

  CurrencyAmount(
    this.originalValue,
    this.originalUnit,
    this.preferredCurrencyUnit,
    this.preferredCurrencyValueRounded,
    this.preferredCurrencyValueApprox,
  );

  static CurrencyAmount fromJson(Map<String, dynamic> json) {
    return CurrencyAmount(
      json['currency_amount_original_value'],
      CurrencyUnit.values.asNameMap()[json['currency_amount_original_unit']] ??
          CurrencyUnit.FUTURE_VALUE,
      CurrencyUnit.values
              .asNameMap()[json['currency_amount_preferred_currency_unit']] ??
          CurrencyUnit.FUTURE_VALUE,
      json['currency_amount_preferred_currency_value_rounded'],
      json['currency_amount_preferred_currency_value_approx'],
    );
  }

  static const fragment = r'''
fragment CurrencyAmountFragment on CurrencyAmount {
    __typename
    currency_amount_original_value: original_value
    currency_amount_original_unit: original_unit
    currency_amount_preferred_currency_unit: preferred_currency_unit
    currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
    currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
}''';
}
