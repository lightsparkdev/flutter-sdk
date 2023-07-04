// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import '../objects/login_with_j_w_t_output.dart';

const LoginWithJwt = '''
  mutation LoginWithJWT(\$account_id: ID!, \$jwt: String!) {
    login_with_jwt(input: { account_id: \$account_id, jwt: \$jwt }) {
        ...LoginWithJWTOutputFragment
    }
  }

  ${LoginWithJWTOutput.fragment}
''';
