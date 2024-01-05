import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:lightspark_wallet/src/auth/jwt/jwt_token_info.dart';

abstract class JwtStorage {
  Future<void> saveToken(JwtTokenInfo token);
  Future<JwtTokenInfo?> getToken();
  Future<void> deleteToken();
}

class InMemoryJwtStorage implements JwtStorage {
  JwtTokenInfo? _tokenInfo;

  @override
  Future<void> deleteToken() {
    _tokenInfo = null;
    return Future.value();
  }

  @override
  Future<JwtTokenInfo?> getToken() {
    return Future.value(_tokenInfo);
  }

  @override
  Future<void> saveToken(JwtTokenInfo token) {
    _tokenInfo = token;
    return Future.value();
  }
}

class SecureStorageJwtStorage implements JwtStorage {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'jwt_token');
  }

  @override
  Future<JwtTokenInfo?> getToken() async {
    final tokenStr = await _secureStorage.read(key: 'jwt_token');
    if (tokenStr == null) {
      return null;
    }
    return _jwtTokenInfoFromJson(tokenStr);
  }

  @override
  Future<void> saveToken(JwtTokenInfo token) async {
    await _secureStorage.write(key: 'jwt_token', value: token.toJson());
  }
}

extension on JwtTokenInfo {
  String toJson() {
    return '{ "accessToken": "$accessToken", "validUntil": "${validUntil.toUtc().toIso8601String()}" }';
  }
}

JwtTokenInfo _jwtTokenInfoFromJson(String json) {
  final decoded = jsonDecode(json);
  return (
    accessToken: decoded['accessToken'],
    validUntil: DateTime.parse(decoded['validUntil']),
  );
}
