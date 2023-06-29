import 'package:lightspark_wallet/src/auth/jwt/jwt_storage.dart';

import '../auth_provider.dart';

class JwtAuthProvider implements AuthProvider {
  final JwtStorage _jwtStorage;

  JwtAuthProvider(this._jwtStorage);

  @override
  String? get authHeaderKey => 'Authorization';

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
