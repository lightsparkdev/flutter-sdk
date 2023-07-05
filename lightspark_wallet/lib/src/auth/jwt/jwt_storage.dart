import 'dart:convert';

import 'package:lightspark_wallet/src/auth/jwt/jwt_token_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class SharedPreferencesJwtStorage implements JwtStorage {
  late final Future<SharedPreferences> _sharedPreferences =
      SharedPreferences.getInstance();

  @override
  Future<void> deleteToken() async {
    await (await _sharedPreferences).remove('jwt_token');
  }

  @override
  Future<JwtTokenInfo?> getToken() async {
    final tokenStr = (await _sharedPreferences).getString('jwt_token');
    if (tokenStr == null) {
      return null;
    }
    return _jwtTokenInfoFromJson(tokenStr);
  }

  @override
  Future<void> saveToken(JwtTokenInfo token) async {
    await (await _sharedPreferences).setString('jwt_token', token.toJson());
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
