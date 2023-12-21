import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:graphql/client.dart';
import 'package:gql/ast.dart';
import 'package:gql/language.dart';
import 'package:lightspark_wallet/src/crypto/crypto.dart';
import 'package:lightspark_wallet/src/crypto/node_key_cache.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

import '../auth/auth_provider.dart';
import './query.dart';

const defaultBaseUrl = 'api.lightspark.com';
const walletSdkEndpoint = 'graphql/wallet/2023-05-05';

String? _packageVersion;
Future<String> _getPackageVersion() async {
  if (_packageVersion != null) {
    return _packageVersion!;
  }
  final pubspecString =
      await rootBundle.loadString('packages/lightspark_wallet/pubspec.yaml');
  final pubspec = Pubspec.parse(pubspecString);
  _packageVersion = pubspec.version?.toString() ?? 'unknown';
  return _packageVersion!;
}

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
          serializer: SigningSerializer(),
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
      SigningLink(nodeKeyCache).concat(_wsLink),
      _authLink.concat(SigningLink(nodeKeyCache)).concat(_httpLink),
    );
    _client = GraphQLClient(
      cache: GraphQLCache(),
      link: _link,
    );
  }

  Future<T> executeQuery<T>(Query<T> query) async {
    var operationNameRegex = RegExp(
        r'^\s*(query|mutation|subscription)\s+(\w+)',
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
    // This may break caching in graphql_flutter, but for now, we're not caching anyway.
    final document = transform(parseString(query.queryPayload), []);
    final result = operationType == 'mutation'
        ? await _client.mutate(
            MutationOptions(
              fetchPolicy: FetchPolicy.noCache,
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
              fetchPolicy: FetchPolicy.noCache,
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
        r'^\s*(query|mutation|subscription)\s+(\w+)',
        caseSensitive: false);
    final operationMatch = operationNameRegex.matchAsPrefix(query.queryPayload);
    if (operationMatch == null || operationMatch.groupCount < 2) {
      throw Exception('Invalid query payload');
    }

    return _client.subscribe<T>(
      SubscriptionOptions(
        fetchPolicy: FetchPolicy.noCache,
        operationName: operationMatch[2],
        document: transform(parseString(query.queryPayload), []),
        variables: query.variables,
        context: Context.fromList([
          NeedsSignature(query.isSignedOp),
          SkipAuth(query.skipAuth),
        ]),
        parserFn: query.constructObject,
      ),
    );
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

class SignatureDetails extends ContextEntry {
  final String signatureJson;
  final String expiration;
  final int nonce;
  const SignatureDetails(
    this.signatureJson,
    this.expiration,
    this.nonce,
  );

  @override
  List<Object?> get fieldsForEquality => [signatureJson, expiration, nonce];
}

class SigningLink extends Link {
  final NodeKeyCache _nodeKeyCache;

  SigningLink(this._nodeKeyCache);

  @override
  Stream<Response> request(Request request, [forward]) async* {
    final packageVersion = await _getPackageVersion();
    final skipAuth = request.context.entry<SkipAuth>()?.skipAuth ?? false;

    request = request.updateContextEntry<HttpLinkHeaders>((entry) {
      final newHeaders = {
        'X-Lightspark-SDK': 'flutter-wallet-sdk/$packageVersion',
        'User-Agent': 'flutter-wallet-sdk/$packageVersion',
      };
      var currentHeaders = entry?.headers ?? <String, String>{};
      if (skipAuth) {
        currentHeaders.remove('Authorization');
      }
      return HttpLinkHeaders(
        headers: {...currentHeaders, ...newHeaders},
      );
    });

    final needsSignature =
        request.context.entry<NeedsSignature>()?.needsSignature ?? false;
    if (!needsSignature) {
      yield* forward!(request);
    }

    final nonce = getNonce();
    final keyPair = _nodeKeyCache.getKeyPair();
    if (keyPair == null) {
      throw Exception('No key pair found for signing');
    }
    final expiration =
        DateTime.now().add(const Duration(hours: 1)).toUtc().toIso8601String();

    final body = const RequestSerializer().serializeRequest(request);
    final bodyWithNonce = {
      ...body,
      'nonce': nonce,
      'expires_at': expiration,
    };
    final signature = await signRsa(
      keyPair.privateKey,
      jsonEncode(bodyWithNonce),
    );
    final signatureJson = jsonEncode({
      'signature': signature,
      'v': 1,
    });

    request = request
        .updateContextEntry<SignatureDetails>(
          (entry) => SignatureDetails(signatureJson, expiration, nonce),
        )
        .updateContextEntry<HttpLinkHeaders>((entry) => entry!
          ..headers.addAll({
            'X-Lightspark-Signing': signatureJson,
          }));

    yield* forward!(request);
  }
}

class SigningSerializer extends RequestSerializer {
  @override
  Map<String, dynamic> serializeRequest(Request request) {
    final body = super.serializeRequest(request);

    final signatureDetails = request.context.entry<SignatureDetails>();
    if (signatureDetails == null) {
      return body;
    }

    final bodyWithNonce = {
      ...body,
      'nonce': signatureDetails.nonce,
      'expires_at': signatureDetails.expiration,
    };

    return bodyWithNonce;
  }
}

class SocketCustomLink extends Link {
  SocketCustomLink(
    this._url,
    this._authProvider,
  );
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
        protocol: GraphQLProtocol.graphqlTransportWs,
        config: SocketClientConfig(
          autoReconnect: true,
          headers: kIsWeb ? null : {},
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
