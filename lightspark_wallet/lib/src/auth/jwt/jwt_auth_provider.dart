import 'package:lightspark_wallet/src/auth/jwt/jwt_storage.dart';
import 'package:lightspark_wallet/src/auth/jwt/jwt_token_info.dart';

import '../auth_provider.dart';

class JwtAuthProvider implements AuthProvider {
  final JwtStorage _jwtStorage;

  JwtAuthProvider(this._jwtStorage);

  @override
  String? get authHeaderKey => 'Authorization';

  Future<void> setTokenInfo(JwtTokenInfo tokenInfo) async {
    await _jwtStorage.saveToken(tokenInfo);
  }

  Future<void> logout() async {
    await _jwtStorage.deleteToken();
  }

  @override
  Future<String?> getAuthToken() async {
    final tokenInfo = await _jwtStorage.getToken();
    if (tokenInfo == null) {
      return null;
    }
    return 'Bearer ${tokenInfo.accessToken}';
  }

  @override
  Future<Map<String, Object>> getWsConnectionParams() {
    // TODO: implement getWsConnectionParams
    throw UnimplementedError();
  }

  @override
  Future<bool> isAuthorized() async {
    final tokenInfo = await _jwtStorage.getToken();
    if (tokenInfo == null) {
      return false;
    }
    return tokenInfo.validUntil.isAfter(DateTime.now());
  }
}
