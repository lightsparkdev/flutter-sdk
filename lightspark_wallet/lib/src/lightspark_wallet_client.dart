import 'package:lightspark_wallet/src/auth/auth_provider.dart';
import 'package:lightspark_wallet/src/auth/jwt/jwt_storage.dart';
import 'package:lightspark_wallet/src/graphql/login_with_jwt.dart';

import 'requester/query.dart';
import 'requester/requester.dart';

class LightsparkWalletClient {
  Requester _requester;
  AuthProvider _authProvider;
  final String _serverUrl;

  LightsparkWalletClient({
    AuthProvider? authProvider,
    String serverUrl = "api.lightspark.com",
  })  : _serverUrl = serverUrl,
        _requester = Requester(
          baseUrl: serverUrl,
          authProvider: authProvider,
        ),
        _authProvider = authProvider ?? StubAuthProvider();

  Future<bool> isAuthorized() async {
    return await _authProvider.isAuthorized();
  }

  setAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
    _requester = Requester(
      baseUrl: _serverUrl,
      authProvider: authProvider,
    );
  }

  Future<void> loginWithJwt(
    String accountId,
    String jwt,
    JwtStorage jwtStorage,
  ) async {
    final response = await _requester.executeQuery(Query(
      LoginWithJwt,
      (jsonData) => jsonData,
      variables: {
        "account_id": accountId,
        "jwt": jwt,
      },
      skipAuth: true
    ));
    print(response);
  }
}
