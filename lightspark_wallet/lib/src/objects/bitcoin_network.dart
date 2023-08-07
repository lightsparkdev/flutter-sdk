// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved
// ignore_for_file: constant_identifier_names

/// This is an enum identifying a particular Bitcoin Network.
enum BitcoinNetwork {
  /// This is an enum value that represents values that could be added in the future.
  /// Clients should support unknown values as more of them could be added without notice.
  FUTURE_VALUE,

  /// The production version of the Bitcoin Blockchain.
  MAINNET,

  /// A test version of the Bitcoin Blockchain, maintained by Lightspark.
  REGTEST,

  /// A test version of the Bitcoin Blockchain, maintained by a centralized organization. Not in use at Lightspark.
  SIGNET,

  /// A test version of the Bitcoin Blockchain, publically available.
  TESTNET,
}
