// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved
// ignore_for_file: constant_identifier_names

enum WalletStatus {
  /// This is an enum value that represents values that could be added in the future.
  /// Clients should support unknown values as more of them could be added without notice.
  FUTURE_VALUE,

  /// The wallet has not been set up yet and is ready to be deployed. This is the default status after the first login.
  NOT_SETUP,

  /// The wallet is currently being deployed in the Lightspark infrastructure.
  DEPLOYING,

  /// The wallet has been deployed in the Lightspark infrastructure and is ready to be initialized.
  DEPLOYED,

  /// The wallet is currently being initialized.
  INITIALIZING,

  /// The wallet is available and ready to be used.
  READY,

  /// The wallet is temporarily available, due to a transient issue or a scheduled maintenance.
  UNAVAILABLE,

  /// The wallet had an unrecoverable failure. This status is not expected to happend and will be investigated by the Lightspark team.
  FAILED,

  /// The wallet is being terminated.
  TERMINATING,

  /// The wallet has been terminated and is not available in the Lightspark infrastructure anymore. It is not connected to the Lightning network and its funds can only be accessed using the Funds Recovery flow.
  TERMINATED,
}
