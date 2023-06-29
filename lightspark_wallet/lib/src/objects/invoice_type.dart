// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved
// ignore_for_file: constant_identifier_names

enum InvoiceType {
  /// This is an enum value that represents values that could be added in the future.
  /// Clients should support unknown values as more of them could be added without notice.
  FUTURE_VALUE,

  /// A standard Bolt 11 invoice.
  STANDARD,

  /// An AMP (Atomic Multi-path Payment) invoice.
  AMP,
}
