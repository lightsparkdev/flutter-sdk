// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved
// ignore_for_file: constant_identifier_names

enum PaymentFailureReason {
  /// This is an enum value that represents values that could be added in the future.
  /// Clients should support unknown values as more of them could be added without notice.
  FUTURE_VALUE,

  NONE,

  TIMEOUT,

  NO_ROUTE,

  ERROR,

  INCORRECT_PAYMENT_DETAILS,

  INSUFFICIENT_BALANCE,

  INVOICE_ALREADY_PAID,

  SELF_PAYMENT,

  INVOICE_EXPIRED,

  RISK_SCREENING_FAILED,
}
