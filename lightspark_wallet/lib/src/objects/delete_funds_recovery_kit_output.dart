// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

class DeleteFundsRecoveryKitOutput {
  final String walletId;

  DeleteFundsRecoveryKitOutput(
    this.walletId,
  );

  static DeleteFundsRecoveryKitOutput fromJson(Map<String, dynamic> json) {
    return DeleteFundsRecoveryKitOutput(
      json['delete_funds_recovery_kit_output_wallet']?['id'],
    );
  }

  static const fragment = r'''
fragment DeleteFundsRecoveryKitOutputFragment on DeleteFundsRecoveryKitOutput {
    __typename
    delete_funds_recovery_kit_output_wallet: wallet {
        id
    }
}''';
}
