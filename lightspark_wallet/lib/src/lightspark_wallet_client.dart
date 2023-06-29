import 'auth/auth_provider.dart';
import 'auth/jwt/jwt_auth_provider.dart';
import 'auth/jwt/jwt_storage.dart';
import 'graphql/login_with_jwt.dart';
import 'objects/login_with_j_w_t_output.dart';
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

  Future<LoginWithJWTOutput> loginWithJwt(
    String accountId,
    String jwt,
    JwtStorage jwtStorage,
  ) async {
    final response = await _requester.executeQuery(
      Query(
        LoginWithJwt,
        (json) => LoginWithJWTOutput.fromJson(json['login_with_jwt']),
        variables: {
          "account_id": accountId,
          "jwt": jwt,
        },
        skipAuth: true,
      ),
    );
    final authProvider = JwtAuthProvider(jwtStorage);
    await authProvider.setTokenInfo((
      accessToken: response.accessToken,
      validUntil: DateTime.parse(response.validUntil),
    ));
    await setAuthProvider(authProvider);

    return response;
  }

  Future<T> executeRawQuery<T>(
    Query<T> query,
  ) async {
    return await _requester.executeQuery(query);
  }
}
