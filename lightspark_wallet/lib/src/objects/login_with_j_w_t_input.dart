
// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved





class LoginWithJWTInput {

    final String accountId;

    final String jwt;


    LoginWithJWTInput(
        this.accountId, this.jwt, 
    );



static LoginWithJWTInput fromJson(Map<String, dynamic> json) {
    return LoginWithJWTInput(
        json["login_with_j_w_t_input_account_id"],
        json["login_with_j_w_t_input_jwt"],

        );

}

}
