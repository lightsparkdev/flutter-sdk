// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './key_type.dart';

class KeyInput {
  final KeyType type;

  final String publicKey;

  KeyInput(
    this.type,
    this.publicKey,
  );

  static KeyInput fromJson(Map<String, dynamic> json) {
    return KeyInput(
      KeyType.values.asNameMap()[json['key_input_type']] ??
          KeyType.FUTURE_VALUE,
      json["key_input_public_key"],
    );
  }
}
