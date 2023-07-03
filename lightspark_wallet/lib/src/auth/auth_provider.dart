abstract interface class AuthProvider {
  Future<String?> getAuthToken();
  String? get authHeaderKey;
  Future<bool> isAuthorized();
  Future<Map<String, dynamic>> getWsConnectionParams();
}

class StubAuthProvider implements AuthProvider {
  @override
  String? get authHeaderKey => null;

  @override
  Future<String?> getAuthToken() {
    return Future.value(null);
  }

  @override
  Future<Map<String, Object>> getWsConnectionParams() {
    return Future.value(<String, Object>{});
  }

  @override
  Future<bool> isAuthorized() {
    return Future.value(false);
  }
}
