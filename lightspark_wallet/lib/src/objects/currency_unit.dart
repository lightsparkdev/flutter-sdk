// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved
// ignore_for_file: constant_identifier_names

/// This enum identifies the unit of currency associated with a CurrencyAmount.
enum CurrencyUnit {
  /// This is an enum value that represents values that could be added in the future.
  /// Clients should support unknown values as more of them could be added without notice.
  FUTURE_VALUE,

  /// Bitcoin is the cryptocurrency native to the Bitcoin network. It is used as the native medium for value transfer for the Lightning Network.
  BITCOIN,

  /// 0.00000001 (10e-8) Bitcoin or one hundred millionth of a Bitcoin. This is the unit most commonly used in Lightning transactions.
  SATOSHI,

  /// 0.001 Satoshi, or 10e-11 Bitcoin. We recommend using the Satoshi unit instead when possible.
  MILLISATOSHI,

  /// United States Dollar.
  USD,

  /// Mexican Peso.
  MXN,

  /// 0.000000001 (10e-9) Bitcoin or a billionth of a Bitcoin. We recommend using the Satoshi unit instead when possible.
  NANOBITCOIN,

  /// 0.000001 (10e-6) Bitcoin or a millionth of a Bitcoin. We recommend using the Satoshi unit instead when possible.
  MICROBITCOIN,

  /// 0.001 (10e-3) Bitcoin or a thousandth of a Bitcoin. We recommend using the Satoshi unit instead when possible.
  MILLIBITCOIN,
}
