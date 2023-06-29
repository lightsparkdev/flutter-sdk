/// An object representing a graphQL query. Includes the query payload, variables, and a function to construct the
/// object from the response.
class Query<T> {
  /// The string representation of the query payload for graphQL. *
  final String queryPayload;

  /// The variables that will be passed to the query. *
  final Map<String, dynamic> variables;

  /// The function that will be called to construct the object from the response. *
  final T Function(Map<String, dynamic>) constructObject;

  /// True if this operation must be signed with the wallet's signing key.
  final bool isSignedOp;

  /// True if auth headers should be omitted for this query. *
  final bool skipAuth;

  Query(
    this.queryPayload,
    this.constructObject, {
    this.variables = const <String, Object>{},
    this.isSignedOp = false,
    this.skipAuth = false,
  });
}
