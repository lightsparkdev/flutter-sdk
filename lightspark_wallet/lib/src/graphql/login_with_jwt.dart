const LoginWithJwt = r'''
mutation LoginWithJWT($account_id: ID!, $jwt: String!) {
  login_with_jwt(input: { account_id: $account_id, jwt: $jwt }) {
      access_token
      valid_until
      wallet {
        id
        status
      }
  }
}
''';
