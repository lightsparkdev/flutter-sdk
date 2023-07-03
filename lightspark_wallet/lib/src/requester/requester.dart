import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:graphql/client.dart';
import 'package:gql/ast.dart';
import 'package:gql/language.dart';
import 'package:lightspark_wallet/src/crypto/crypto.dart';
import 'package:lightspark_wallet/src/crypto/node_key_cache.dart';

import '../auth/auth_provider.dart';
import './query.dart';

const defaultBaseUrl = 'api.lightspark.com';
const walletSdkEndpoint = "graphql/wallet/2023-05-05";

// TODO(Jeremy): Add SDK version and platform info user agent.
const _defaultHeaders = {
  "X-Lightspark-SDK": "flutter-wallet-sdk",
  "User-Agent": "flutter-wallet-sdk",
  "X-Lightspark-Beta": "z2h0BBYxTA83cjW7fi8QwWtBPCzkQKiemcuhKY08LOo",
};

class Requester {
  final AuthProvider _authProvider;
  final HttpLink _httpLink;
  late SocketCustomLink _wsLink;
  late AuthLink _authLink;
  late Link _link;
  late final GraphQLClient _client;

  Requester(
    NodeKeyCache nodeKeyCache, {
    String baseUrl = defaultBaseUrl,
    AuthProvider? authProvider,
  })  : _httpLink = HttpLink(
          'https://$baseUrl/$walletSdkEndpoint',
          defaultHeaders: _defaultHeaders,
          serializer: SigningSerializer(nodeKeyCache),
        ),
        _authProvider = authProvider ?? StubAuthProvider() {
    _authLink = AuthLink(
      getToken: () => _authProvider.getAuthToken(),
      headerKey: _authProvider.authHeaderKey ?? 'Authorization',
    );
    _wsLink = SocketCustomLink(
      'wss://$baseUrl/$walletSdkEndpoint',
      _authProvider,
    );
    _link = Link.split(
      (request) => request.isSubscription,
      _wsLink,
      _authLink.concat(_httpLink),
    );
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
    final document = query.skipAuth
        ? transform(
            parseString(query.queryPayload),
            [],
          )
        : gql(query.queryPayload);
    final result = operationType == 'mutation'
        ? await _client.mutate(
            MutationOptions(
              operationName: operationMatch[2],
              document: document,
              variables: query.variables,
              context: Context.fromList([
                NeedsSignature(query.isSignedOp),
                SkipAuth(query.skipAuth),
              ]),
            ),
          )
        : await _client.query(
            QueryOptions(
              operationName: operationMatch[2],
              document: document,
              variables: query.variables,
              context: Context.fromList([
                NeedsSignature(query.isSignedOp),
                SkipAuth(query.skipAuth),
              ]),
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

  Stream<QueryResult<T>> executeSubscription<T>(Query<T> query) {
    final operationNameRegex = RegExp(
        r"^\s*(query|mutation|subscription)\s+(\w+)",
        caseSensitive: false);
    final operationMatch = operationNameRegex.matchAsPrefix(query.queryPayload);
    if (operationMatch == null || operationMatch.groupCount < 2) {
      throw Exception('Invalid query payload');
    }

    return _client
        .subscribe(
      SubscriptionOptions(
        operationName: operationMatch[2],
        document: gql(query.queryPayload),
        variables: query.variables,
        context: Context.fromList([
          NeedsSignature(query.isSignedOp),
          SkipAuth(query.skipAuth),
        ]),
      ),
    )
        .map((event) {
      event.parserFn = query.constructObject;
      return event as QueryResult<T>;
    });
  }
}

class SkipAuth extends ContextEntry {
  final bool skipAuth;
  const SkipAuth(this.skipAuth);

  @override
  List<Object?> get fieldsForEquality => [skipAuth];
}

class NeedsSignature extends ContextEntry {
  final bool needsSignature;
  const NeedsSignature(this.needsSignature);

  @override
  List<Object?> get fieldsForEquality => [needsSignature];
}

class SigningSerializer extends RequestSerializer {
  final NodeKeyCache _nodeKeyCache;

  SigningSerializer(this._nodeKeyCache);

  @override
  Map<String, dynamic> serializeRequest(Request request) {
    final body = super.serializeRequest(request);

    final skipAuth = request.context.entry<SkipAuth>()?.skipAuth ?? false;
    if (skipAuth) {
      request.updateContextEntry<HttpLinkHeaders>(
          (entry) => entry!..headers.remove('Authorization'));
    }

    final needsSignature =
        request.context.entry<NeedsSignature>()?.needsSignature ?? false;
    if (!needsSignature) {
      return body;
    }

    final nonce = getNonce();
    final keyPair = _nodeKeyCache.getKeyPair();
    if (keyPair == null) {
      throw Exception('No key pair found for signing');
    }

    final bodyWithNonce = {
      ...body,
      'nonce': nonce,
      'expires_at':
          DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
    };
    final signature = signRsa(
      keyPair.privateKey,
      jsonEncode(bodyWithNonce),
    );
    final signatureJson = jsonEncode({
      'signature': signature,
      'v': 1,
    });

    request.updateContextEntry<HttpLinkHeaders>((entry) => entry!
      ..headers.addAll({
        'X-Lightspark-Signing': signatureJson,
      }));
    return bodyWithNonce;
  }
}

class SocketCustomLink extends Link {
  SocketCustomLink(this._url, this._authProvider);
  final String _url;
  final AuthProvider _authProvider;
  _WsConnection? _connection;

  @override
  Stream<Response> request(Request request, [forward]) async* {
    final connectionParams = await _authProvider.getWsConnectionParams();

    /// check is connection is null or the token changed
    if (_connection == null ||
        !_paramsEqual(_connection!.connectionParams, connectionParams)) {
      _connectOrReconnect(connectionParams);
    }
    yield* _connection!.client.subscribe(request, true);
  }

  bool _paramsEqual(
      Map<String, dynamic>? paramsA, Map<String, dynamic>? paramsB) {
    if (paramsA == null && paramsB == null) {
      return true;
    }
    if (paramsA == null || paramsB == null) {
      return false;
    }
    if (paramsA.length != paramsB.length) {
      return false;
    }

    for (var key in paramsA.keys) {
      if (paramsA[key] != paramsB[key]) {
        return false;
      }
    }

    return true;
  }

  void _connectOrReconnect(Map<String, dynamic>? connectionParams) {
    _connection?.client.dispose();
    var url = Uri.parse(_url);
    _connection = _WsConnection(
      client: SocketClient(
        url.toString(),
        config: SocketClientConfig(
          autoReconnect: true,
          headers: kIsWeb ? null : _defaultHeaders,
          inactivityTimeout: const Duration(seconds: 30),
          initialPayload: connectionParams,
        ),
      ),
      connectionParams: connectionParams,
    );
  }

  @override
  Future<void> dispose() async {
    await _connection?.client.dispose();
    _connection = null;
  }
}

/// this a wrapper for web socket to hold the used token
class _WsConnection {
  SocketClient client;
  Map<String, dynamic>? connectionParams;
  _WsConnection({
    required this.client,
    required this.connectionParams,
  });
}
