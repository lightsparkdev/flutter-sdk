import 'package:graphql/client.dart';
import 'package:gql/ast.dart';
import 'package:gql/language.dart';

import '../auth/auth_provider.dart';
import './query.dart';

const defaultBaseUrl = 'api.lightspark.com';
const walletSdkEndpoint = "graphql/wallet/2023-05-05";

class Requester {
  final AuthProvider _authProvider;
  final HttpLink _httpLink;
  late AuthLink _authLink;
  late Link _link;
  late final GraphQLClient _client;

  Requester({
    String baseUrl = defaultBaseUrl,
    AuthProvider? authProvider,
  })  : _httpLink = HttpLink(
          'https://$baseUrl/$walletSdkEndpoint',
          // TODO(Jeremy): Add SDK version and platform info user agent.
          defaultHeaders: {
            "X-Lightspark-SDK": "flutter-wallet-sdk",
            "User-Agent": "flutter-wallet-sdk",
            "X-Lightspark-Beta": "z2h0BBYxTA83cjW7fi8QwWtBPCzkQKiemcuhKY08LOo",
          },
        ),
        _authProvider = authProvider ?? StubAuthProvider() {
    // TODO(Jeremy): Add websocket support.
    _authLink = AuthLink(
      getToken: () => _authProvider.getAuthToken(),
      headerKey: _authProvider.authHeaderKey ?? 'Authorization',
    );
    _link = _authLink.concat(_httpLink);
    _client = GraphQLClient(
      cache: GraphQLCache(),
      link: _link,
    );
  }

  Future<T> executeQuery<T>(Query<T> query) async {
    var operationNameRegex = RegExp(
        r"^\s*(query|mutation|subscription)\s+(\w+)",
        caseSensitive: false);
    var operationMatch = operationNameRegex.matchAsPrefix(query.queryPayload);
    if (operationMatch == null || operationMatch.groupCount < 2) {
      throw Exception('Invalid query payload');
    }
    String operationType = operationMatch[1]!;
    if (operationType == 'subscription') {
      throw Exception('Subscription queries should call subscribe instead');
    }
    // This is a bit weird, but for public endpoints, we need to avoid adding the __typename field to the query.
    // This may break caching in graphql_flutter, so keep it when we can.
    final document = query.skipAuth ? transform(
      parseString(query.queryPayload),
      [],
    ) : gql(query.queryPayload);
    // TODO(Jeremy): Add signing support.
    final result = operationType == 'mutation'
        ? await _client.mutate(
            MutationOptions(
              operationName: operationMatch[2],
              document: document,
              variables: query.variables,
            ),
          )
        : await _client.query(
            QueryOptions(
              operationName: operationMatch[2],
              document: document,
              variables: query.variables,
            ),
          );
    if (result.hasException) {
      throw result.exception!;
    }
    if (result.data == null) {
      throw Exception('Query returned null data');
    }
    return query.constructObject(result.data!);
  }
}
