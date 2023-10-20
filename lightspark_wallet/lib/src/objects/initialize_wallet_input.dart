// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './key_input.dart';

class InitializeWalletInput {
  final KeyInput signingPublicKey;

  InitializeWalletInput(
    this.signingPublicKey,
  );

  static InitializeWalletInput fromJson(Map<String, dynamic> json) {
    return InitializeWalletInput(
      KeyInput.fromJson(json["initialize_wallet_input_signing_public_key"]),
    );
  }
}
