
// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved
// ignore_for_file: constant_identifier_names

/// This is an enum of the potential statuses that a Withdrawal can take.
enum WithdrawalRequestStatus {
 /// This is an enum value that represents values that could be added in the future.
 /// Clients should support unknown values as more of them could be added without notice.
 FUTURE_VALUE,

CREATING,

CREATED,

FAILED,

IN_PROGRESS,

SUCCESSFUL,

PARTIALLY_SUCCESSFUL,

}

