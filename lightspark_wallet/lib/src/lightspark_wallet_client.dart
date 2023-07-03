import 'dart:async';

import 'package:fast_rsa/fast_rsa.dart';
import 'package:graphql/client.dart';
import 'package:lightspark_wallet/src/crypto/crypto.dart';
import 'package:lightspark_wallet/src/crypto/node_key_cache.dart';
import 'package:lightspark_wallet/src/graphql/lightning_fee_estimate_for_invoice.dart';
import 'package:lightspark_wallet/src/graphql/lightning_fee_estimate_for_node.dart';
import 'package:lightspark_wallet/src/objects/objects.dart';

import 'auth/auth_provider.dart';
import 'auth/jwt/jwt_auth_provider.dart';
import 'auth/jwt/jwt_storage.dart';
import 'auth/lightspark_auth_exception.dart';
import 'graphql/bitcoin_fee_estimate.dart';
import 'graphql/create_bitcoin_funding_address.dart';
import 'graphql/create_invoice.dart';
import 'graphql/create_test_mode_invoice.dart';
import 'graphql/create_test_mode_payment.dart';
import 'graphql/current_wallet.dart';
import 'graphql/decode_invoice.dart';
import 'graphql/deploy_wallet.dart';
import 'graphql/initialize_wallet.dart';
import 'graphql/login_with_jwt.dart';
import 'graphql/pay_invoice.dart';
import 'graphql/request_withdrawal.dart';
import 'graphql/send_payment.dart';
import 'graphql/terminate_wallet.dart';
import 'graphql/wallet_dashboard.dart';
import 'lightspark_exception.dart';
import 'requester/query.dart';
import 'requester/requester.dart';

class LightsparkWalletClient {
  late Requester _requester;
  AuthProvider _authProvider;
  final String _serverUrl;
  final NodeKeyCache _nodeKeyCache = NodeKeyCache();

  LightsparkWalletClient({
    AuthProvider? authProvider,
    String serverUrl = "api.lightspark.com",
  })  : _serverUrl = serverUrl,
        _authProvider = authProvider ?? StubAuthProvider() {
    _requester = Requester(
      _nodeKeyCache,
      baseUrl: serverUrl,
      authProvider: authProvider,
    );
  }

  Future<bool> isAuthorized() async {
    return await _authProvider.isAuthorized();
  }

  void setAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
    _requester = Requester(
      _nodeKeyCache,
      baseUrl: _serverUrl,
      authProvider: authProvider,
    );
  }

  /// Login using the Custom JWT authentication scheme described in our documentation.
  ///
  /// Note: When using this method, you are responsible for refreshing the JWT token before or when it expires. If the
  /// token expires, the client will throw a [LightsparkAuthException] on the next API call which requires
  /// valid authentication. Then you'll need to call this method again to get a new token.
  ///
  /// [accountId] The account ID to login with. This is specific to your company's account.
  /// [jwt] The JWT to use for authentication of this user.
  /// [jwtStorage] The storage to use for storing the JWT token.
  /// Returns the output of the login operation, including the access token, expiration time, and wallet info.
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
    setAuthProvider(authProvider);

    return response;
  }

  /// Get the current [Wallet] if one exists, null otherwise.
  Future<Wallet?> getCurrentWallet() async {
    await _requireValidAuth();
    return await executeRawQuery(Query(
      CurrentWalletQuery,
      (responseJson) {
        if (responseJson["current_wallet"] == null) {
          return null;
        }
        return Wallet.fromJson(responseJson["current_wallet"]);
      },
    ));
  }

  /// Deploys a wallet in the Lightspark infrastructure. This is an asynchronous operation, the caller should then poll
  /// the wallet frequently (or subscribe to its modifications). When this process is over, the Wallet status will
  /// change to [WalletStatus.DEPLOYED] (or [WalletStatus.FAILED]).
  ///
  /// Returns the [Wallet] that was deployed.
  Future<Wallet> deployWallet() async {
    await _requireValidAuth();
    return await executeRawQuery(Query(
      DeployWallet,
      (responseJson) =>
          DeployWalletOutput.fromJson(responseJson["deploy_wallet"]).wallet,
    ));
  }

  /// Deploys a wallet in the Lightspark infrastructure and waits for it to be deployed.
  /// This is an asynchronous operation, which will continue processing wallet status updates until
  /// the Wallet status changes to [WalletStatus.DEPLOYED] (or [WalletStatus.FAILED]).
  ///
  /// Returns the [WalletStatus] indicating whether the wallet was successfully deployed or failed.
  /// Throws a [LightsparkException] if the wallet status is not  [WalletStatus.DEPLOYED] or [WalletStatus.FAILED]
  /// after 60 seconds, or if the subscription fails.
  Future<WalletStatus> deployWalletAndAwaitDeployed() async {
    final wallet = await deployWallet();
    if (wallet.status == WalletStatus.DEPLOYED ||
        wallet.status == WalletStatus.FAILED) {
      return wallet.status;
    }
    return await _waitForWalletStatus([
      WalletStatus.DEPLOYED,
      WalletStatus.FAILED,
    ]);
  }

  Future<WalletStatus> _waitForWalletStatus(
    List<WalletStatus> statuses, {
    int timeoutSecs = 60,
  }) async {
    var wallet = await getCurrentWallet();
    if (statuses.contains(wallet?.status)) {
      return wallet!.status;
    }

    final resultCompleter = Completer<WalletStatus>();
    final subscription = executeRawSubscription(Query(
      r'''
        subscription WalletStatusSubscription {
          current_wallet {
            status
          }
        }''',
      (json) =>
          WalletStatus.values.asNameMap()[json["current_wallet"]["status"]] ??
          WalletStatus.FUTURE_VALUE,
    )).timeout(Duration(seconds: timeoutSecs));

    final subscriptionStream = subscription.listen((event) {
      if (statuses.contains(event.parsedData)) {
        resultCompleter.complete(event.parsedData);
      }
    });

    resultCompleter.future.then((_) {
      subscriptionStream.cancel();
    }).catchError((_) {
      subscriptionStream.cancel();
    });

    subscriptionStream.onDone(() {
      if (!resultCompleter.isCompleted) {
        resultCompleter.completeError(LightsparkException(
          "WalletStatusAwaitError",
          "Wallet status subscription completed without receiving a status update.",
        ));
      }
    });

    return resultCompleter.future;
  }

  /// Initializes a wallet in the Lightspark infrastructure and syncs it to the Bitcoin network. This is an
  /// asynchronous operation, the caller should then poll the wallet frequently (or subscribe to its modifications).
  /// When this process is over, the Wallet status will change to `READY` (or `FAILED`).
  ///
  /// [keyType] The type of key to use for the wallet.
  /// [signingPublicKey] The base64-encoded public key to use for signing transactions.
  /// [signingPrivateKey] An object containing either the base64-encoded private key. The key will be
  ///     used for signing transactions. This key will not leave the device. It is only used for
  ///     signing transactions locally.
  /// Returns the [Wallet] that was initialized.
  Future<Wallet> initializeWallet(
    KeyType keyType,
    String signingPublicKey,
    String signingPrivateKey,
  ) async {
    await _requireValidAuth();
    loadWalletSigningKey(signingPublicKey, signingPrivateKey);
    return await executeRawQuery(Query(
      InitializeWallet,
      (responseJson) =>
          InitializeWalletOutput.fromJson(responseJson["initialize_wallet"])
              .wallet,
      variables: {
        "key_type": keyType.name,
        "signing_public_key": stripPemTags(signingPublicKey),
      },
      isSignedOp: true,
    ));
  }

  /// Initializes a wallet in the Lightspark infrastructure and syncs it to the Bitcoin network.
  /// This is an asynchronous operation, which will continue processing wallet status updates until
  /// the Wallet status changes to [WalletStatus.READY] (or [WalletStatus.FAILED]).
  ///
  /// [keyType] The type of key to use for the wallet.
  /// [signingPublicKey] The base64-encoded public key to use for signing transactions.
  /// [signingPrivateKey] An object containing either the base64-encoded private key. The key will be
  ///     used for signing transactions. This key will not leave the device. It is only used for
  ///     signing transactions locally.
  /// Returns a [Future] with the final wallet status after initialization or failure.
  /// Throws a [LightsparkException] if the wallet status is not [WalletStatus.READY] or
  ///     [WalletStatus.FAILED] after 5 minutes, or if the subscription fails.
  Future<WalletStatus> initializeWalletAndAwaitReady(
    KeyType keyType,
    String signingPublicKey,
    String signingPrivateKey,
  ) async {
    final wallet = await initializeWallet(
      keyType,
      signingPublicKey,
      signingPrivateKey,
    );
    if (wallet.status == WalletStatus.READY ||
        wallet.status == WalletStatus.FAILED) {
      return wallet.status;
    }
    return await _waitForWalletStatus(
      [WalletStatus.READY, WalletStatus.FAILED],
      timeoutSecs: 300,
    );
  }

  /// Unlocks the wallet for use with the SDK for the current application session. This function
  /// must be called before any other functions that require wallet signing keys, including [payInvoice].
  ///
  /// This function is intended for use in cases where the wallet's private signing key is already saved by the
  /// application outside of the SDK. It is the responsibility of the application to ensure that the key is valid and
  /// that it is the correct key for the wallet. Otherwise signed requests will fail.
  void loadWalletSigningKey(String publicKey, String privateKey) {
    _nodeKeyCache.setKeyPair(KeyPair(publicKey, privateKey));
  }

  /// Removes the wallet from Lightspark infrastructure. It won't be connected to the Lightning network anymore and
  /// its funds won't be accessible outside of the Funds Recovery Kit process.
  ///
  /// Returns the [Wallet] that was terminated.
  Future<Wallet> terminateWallet() async {
    await _requireValidAuth();
    return await executeRawQuery(Query(
      TerminateWallet,
      (responseJson) =>
          TerminateWalletOutput.fromJson(responseJson["terminate_wallet"])
              .wallet,
    ));
  }

  /// Get the dashboard overview for a Lightning wallet. Includes balance info and
  /// the most recent transactions and payment requests.
  ///
  /// [numTransactions] The max number of recent transactions to fetch. Defaults to 20.
  /// [numPaymentRequests] The max number of recent payment requests to fetch. Defaults to 20.
  getWalletDashboard(
      {int numTransactions = 20, int numPaymentRequests = 20}) async {
    await _requireValidAuth();
    return await executeRawQuery(Query(
      WalletDashboardQuery,
      (responseJson) {
        final currentWallet = responseJson["current_wallet"];
        if (currentWallet == null) {
          return null;
        }
        return WalletDashboard(
          id: currentWallet["id"],
          status: WalletStatus.values.asNameMap()[currentWallet["status"]] ??
              WalletStatus.FUTURE_VALUE,
          balances: currentWallet["balances"] != null
              ? Balances.fromJson(currentWallet["balances"])
              : null,
          recentTransactions: WalletToTransactionsConnection.fromJson(
            currentWallet["recent_transactions"],
          ),
          paymentRequests: WalletToPaymentRequestsConnection.fromJson(
            currentWallet["payment_requests"],
          ),
        );
      },
      variables: {
        "numTransactions": numTransactions,
        "numPaymentRequests": numPaymentRequests,
      },
    ));
  }

  /// Creates a lightning invoice from the current wallet.
  ///
  /// Test mode note: You can simulate a payment of this invoice in test move using [createTestModePayment].
  ///
  /// [amountMsats] The amount of the invoice in milli-satoshis.
  /// [memo] Optional memo to include in the invoice.
  /// [type] The type of invoice to create. Defaults to [InvoiceType.STANDARD].
  Future<InvoiceData> createInvoice(int amountMsats,
      {String? memo, InvoiceType type = InvoiceType.STANDARD}) async {
    await _requireValidAuth();
    return await executeRawQuery(Query(
      CreateInvoiceMutation,
      (responseJson) => InvoiceData.fromJson(
          responseJson["create_invoice"]["invoice"]["data"]),
      variables: {
        "amountMsats": amountMsats,
        "memo": memo,
        "type": type.name,
      },
    ));
  }

  /// Decode a lightning invoice to get its details included payment amount, destination, etc.
  ///
  /// [encodedInvoice] An encoded string representation of the invoice to decode.
  Future<InvoiceData> decodeInvoice(String encodedInvoice) async {
    return await executeRawQuery(Query(
      DecodeInvoiceQuery,
      (responseJson) =>
          InvoiceData.fromJson(responseJson["decoded_payment_request"]),
      variables: {
        "encoded_payment_request": encodedInvoice,
      },
    ));
  }

  /// Pay a lightning invoice from the current wallet. This function will return immediately with the payment details,
  /// which may still be in a PENDING state. You can use the [payInvoiceAndAwaitResult] function to wait for the payment
  /// to complete or fail.
  ///
  /// Note: This call will fail if the wallet is not unlocked yet via [loadWalletSigningKey]. You must successfully
  /// unlock the wallet before calling this function.
  ///
  /// Test mode note: For test mode, you can use the [createTestModeInvoice] function to create an invoice you can
  /// pay in test mode.
  ///
  /// [encodedInvoice] An encoded string representation of the invoice to pay.
  /// [maxFeesMsats] The maximum fees to pay in milli-satoshis. You must pass a value.
  ///     As guidance, a maximum fee of 15 basis points should make almost all transactions succeed. For example,
  ///     for a transaction between 10k sats and 100k sats, this would mean a fee limit of 15 to 150 sats.
  /// [amountMsats] The amount to pay in milli-satoshis. Defaults to the full amount of the invoice.
  /// [timeoutSecs] The number of seconds to wait for the payment to complete. Defaults to 60.
  /// Returns the payment details, which may still be in a PENDING state. You can use the [payInvoiceAndAwaitResult]
  ///     function to wait for the payment to complete or fail.
  Future<OutgoingPayment> payInvoice(
    String encodedInvoice,
    int maxFeesMsats, {
    int? amountMsats,
    int timeoutSecs = 60,
  }) async {
    await _requireValidAuth();
    await _requireWalletUnlocked();
    final variables = {
      "encoded_invoice": encodedInvoice,
      "maximum_fees_msats": maxFeesMsats,
      "timeout_secs": timeoutSecs,
    };
    if (amountMsats != null) {
      variables["amount_msats"] = amountMsats;
    }
    final payment = await executeRawQuery(Query(
      PayInvoiceMutation,
      (responseJson) {
        final paymentJson = responseJson["pay_invoice"]?["payment"];
        if (paymentJson == null) {
          return null;
        }
        return OutgoingPayment.fromJson(paymentJson);
      },
      variables: variables,
      isSignedOp: true,
    ));
    if (payment == null) {
      throw LightsparkException(
        "PaymentNullError",
        "Unknown error paying invoice",
      );
    }
    return payment;
  }

  /// Pay a lightning invoice from the current wallet and wait for the payment to complete or fail.
  ///
  /// Note: This call will fail if the wallet is not unlocked yet via [loadWalletSigningKey]. You must successfully
  /// unlock the wallet before calling this function.
  ///
  /// [encodedInvoice] An encoded string representation of the invoice to pay.
  /// [maxFeesMsats] The maximum fees to pay in milli-satoshis. You must pass a value.
  ///     As guidance, a maximum fee of 15 basis points should make almost all transactions succeed. For example,
  ///     for a transaction between 10k sats and 100k sats, this would mean a fee limit of 15 to 150 sats.
  /// [amountMsats] The amount to pay in milli-satoshis. Defaults to the full amount of the invoice.
  /// [timeoutSecs] The number of seconds to wait for the payment to complete. Defaults to 60.
  /// Returns the completed payment details.
  Future<OutgoingPayment> payInvoiceAndAwaitResult(
    String encodedInvoice,
    int maxFeesMsats, {
    int? amountMsats,
    int timeoutSecs = 60,
  }) async {
    final payment = await payInvoice(
      encodedInvoice,
      maxFeesMsats,
      amountMsats: amountMsats,
      timeoutSecs: timeoutSecs,
    );
    return await _waitForPaymentResult(
      payment,
      timeoutSecs: timeoutSecs,
    );
  }

  /// Sends a payment directly to a node on the Lightning Network through the public key of the node without an invoice.
  /// This function will return immediately with the payment details, which may still be in a PENDING state. You can use
  /// the [sendPaymentAndAwaitResult] function to wait for the payment to complete or fail.
  ///
  /// [destinationNodePublicKey] The public key of the destination node.
  /// [amountMsats] The amount to pay in milli-satoshis.
  /// [maxFeesMsats] The maximum amount of fees that you want to pay for this payment to be sent.
  ///     As guidance, a maximum fee of 15 basis points should make almost all transactions succeed. For example,
  ///     for a transaction between 10k sats and 100k sats, this would mean a fee limit of 15 to 150 sats.
  /// [timeoutSecs] The timeout in seconds that we will try to make the payment.
  /// Returns an [OutgoingPayment] object, which may still be in a PENDING state. You can use the
  ///     [sendPaymentAndAwaitResult] function to wait for the payment to complete or fail.
  Future<OutgoingPayment> sendPayment(
    String destinationNodePublicKey,
    int amountMsats,
    int maxFeesMsats, {
    int timeoutSecs = 60,
  }) async {
    await _requireValidAuth();
    await _requireWalletUnlocked();
    final payment = await executeRawQuery(Query(
      SendPaymentMutation,
      (responseJson) {
        final paymentJson = responseJson["send_payment"]?["payment"];
        if (paymentJson == null) {
          return null;
        }
        return OutgoingPayment.fromJson(paymentJson);
      },
      variables: {
        "destination_node_public_key": destinationNodePublicKey,
        "amount_msats": amountMsats,
        "maximum_fees_msats": maxFeesMsats,
        "timeout_secs": timeoutSecs,
      },
      isSignedOp: true,
    ));
    if (payment == null) {
      throw LightsparkException(
        "PaymentNullError",
        "Unknown error sending payment",
      );
    }
    return payment;
  }

  /// Sends a payment directly to a node on the Lightning Network through the public key of the node without an invoice.
  /// Waits for the payment to complete or fail.
  ///
  /// [destinationNodePublicKey] The public key of the destination node.
  /// [amountMsats] The amount to pay in milli-satoshis.
  /// [maxFeesMsats] The maximum amount of fees that you want to pay for this payment to be sent.
  ///     As guidance, a maximum fee of 15 basis points should make almost all transactions succeed. For example,
  ///     for a transaction between 10k sats and 100k sats, this would mean a fee limit of 15 to 150 sats.
  /// [timeoutSecs] The timeout in seconds that we will try to make the payment.
  /// Returns an [OutgoingPayment] object. Check the [OutgoingPayment.status] field to see if the payment succeeded or failed.
  Future<OutgoingPayment> sendPaymentAndAwaitResult(
    String destinationNodePublicKey,
    int amountMsats,
    int maxFeesMsats, {
    int timeoutSecs = 60,
  }) async {
    final payment = await sendPayment(
      destinationNodePublicKey,
      amountMsats,
      maxFeesMsats,
      timeoutSecs: timeoutSecs,
    );
    return await _waitForPaymentResult(payment, timeoutSecs: timeoutSecs);
  }

  Future<OutgoingPayment> _waitForPaymentResult(
    OutgoingPayment initialPayment, {
    int timeoutSecs = 60,
  }) async {
    // TODO(Jeremy): Switch to subscription.
    const completionStatuses = [
      TransactionStatus.FAILED,
      TransactionStatus.CANCELLED,
      TransactionStatus.SUCCESS,
    ];
    const delayIncrementSec = 2;
    var payment = initialPayment;
    var totalDelay = 0;
    while (!completionStatuses.contains(payment.status) &&
        totalDelay < timeoutSecs) {
      await Future.delayed(const Duration(seconds: delayIncrementSec));
      totalDelay += delayIncrementSec;
      payment = await executeRawQuery(
          OutgoingPayment.getOutgoingPaymentQuery(payment.id));
    }
    if (!completionStatuses.contains(payment.status)) {
      throw LightsparkException(
        "PaymentTimeoutError",
        "Payment did not complete before the timeout of $timeoutSecs seconds.",
      );
    }
    return payment;
  }

  /// Gets an estimate of the fee for sending a payment over the given bitcoin network, including a
  /// minimum fee rate, and a max-speed fee rate.
  Future<FeeEstimate> getBitcoinFeeEstimate() async {
    return await executeRawQuery(Query(
      BitcoinFeeEstimateQuery,
      (responseJson) =>
          FeeEstimate.fromJson(responseJson["bitcoin_fee_estimate"]),
    ));
  }

  /// Gets an estimate of the fees that will be paid for a Lightning invoice.
  ///
  /// [encodedPaymentRequest] The invoice you want to pay (as defined by the BOLT11 standard).
  /// [amountMsats] If the invoice does not specify a payment amount, then the amount that you wish to pay,
  ///     expressed in msats.
  Future<CurrencyAmount> getLightningFeeEstimateForInvoice(
      String encodedPaymentRequest,
      [int? amountMsats]) async {
    await _requireValidAuth();
    return await executeRawQuery(
      Query(
        LightningFeeEstimateForInvoiceQuery,
        (json) => CurrencyAmount.fromJson(
            json["lightning_fee_estimate_for_invoice"]["fee_estimate"]),
        variables: {
          "encoded_payment_request": encodedPaymentRequest,
          "amount_msats": amountMsats,
        },
      ),
    );
  }

  /// Returns an estimate of the fees that will be paid to send a payment to another Lightning node.
  ///
  /// [destinationNodePublicKey] The public key of the node that you want to pay.
  /// [amountMsats] The payment amount expressed in msats.
  Future<CurrencyAmount> getLightningFeeEstimateForNode(
      String destinationNodePublicKey, int amountMsats) async {
    await _requireValidAuth();
    return await executeRawQuery(
      Query(
        LightningFeeEstimateForNodeQuery,
        (json) => CurrencyAmount.fromJson(
            json["lightning_fee_estimate_for_node"]["fee_estimate"]),
        variables: {
          "destination_node_public_key": destinationNodePublicKey,
          "amount_msats": amountMsats,
        },
      ),
    );
  }

  /// Creates an L1 Bitcoin wallet address which can be used to deposit funds to the Lightning wallet.
  Future<String> createBitcoinFundingAddress() async {
    await _requireValidAuth();
    await _requireWalletUnlocked();
    return await executeRawQuery(Query(
      CreateBitcoinFundingAddress,
      (responseJson) => responseJson["create_bitcoin_funding_address"]
          ["bitcoin_address"] as String,
      isSignedOp: true,
    ));
  }

  /// Withdraws funds from the account and sends it to the requested bitcoin address.
  ///
  /// The process is asynchronous and may take up to a few minutes. You can check the progress by polling the
  /// `WithdrawalRequest` that is created, or by subscribing to a webhook.
  ///
  /// [amountSats] The amount of funds to withdraw in SATOSHI.
  /// [bitcoinAddress] The Bitcoin address to withdraw funds to.
  Future<WithdrawalRequest?> requestWithdrawal(
    int amountSats,
    String bitcoinAddress,
  ) async {
    await _requireValidAuth();
    await _requireWalletUnlocked();
    return await executeRawQuery(Query(
      RequestWithdrawalMutation,
      (responseJson) {
        final request = responseJson["request_withdrawal"]?["request"];
        if (request == null) {
          return null;
        }
        return WithdrawalRequest.fromJson(request);
      },
      variables: {
        "amount_sats": amountSats,
        "bitcoin_address": bitcoinAddress,
      },
      isSignedOp: true,
    ));
  }

  /// In test mode, generates a Lightning Invoice which can be paid by a local node.
  /// This call is only valid in test mode. You can then pay the invoice using [payInvoice].
  ///
  /// [amountMsats] The amount to pay in milli-satoshis.
  /// [memo] An optional memo to attach to the invoice.
  /// [invoiceType] The type of invoice to create.
  Future<String?> createTestModeInvoice(
    int amountMsats, {
    String? memo,
    InvoiceType invoiceType = InvoiceType.STANDARD,
  }) async {
    await _requireValidAuth();
    return await executeRawQuery(Query(
      CreateTestModeInvoice,
      (responseJson) {
        final encodedPaymentRequest = responseJson["create_test_mode_invoice"]
            ?["encoded_payment_request"];
        if (encodedPaymentRequest == null) {
          throw LightsparkException("CreateTestModeInvoiceError",
              "Unable to create test mode invoice");
        }
        return encodedPaymentRequest as String;
      },
      variables: {
        "amount_msats": amountMsats,
        "memo": memo,
        "invoice_type": invoiceType.name,
      },
    ));
  }

  /// In test mode, simulates a payment of a Lightning Invoice from another node.
  /// This can only be used in test mode and should be used with invoices generated by [createInvoice].
  ///
  /// [encodedInvoice] The encoded invoice to pay.
  /// [amountMsats] The amount to pay in milli-satoshis for 0-amount invoices. This should be null for non-zero
  ///     amount invoices.
  Future<OutgoingPayment?> createTestModePayment(
    String encodedInvoice, [
    int? amountMsats,
  ]) async {
    await _requireValidAuth();
    _requireWalletUnlocked();
    return await executeRawQuery(Query(
      CreateTestModePayment,
      (responseJson) {
        final paymentJson =
            responseJson["create_test_mode_payment"]?["payment"];
        if (paymentJson == null) {
          return null;
        }
        return OutgoingPayment.fromJson(paymentJson);
      },
      variables: {
        "encoded_invoice": encodedInvoice,
        "amount_msats": amountMsats,
      },
      isSignedOp: true,
    ));
  }

  /// Returns true if the wallet is unlocked or false if it is locked.
  bool isWalletUnlocked() {
    return false; //this.nodeKeyCache.hasKey(WALLET_NODE_ID_KEY);
  }

  _requireWalletUnlocked() {
    if (!isWalletUnlocked()) {
      throw LightsparkAuthException(
          "You must unlock the wallet before performing this action.");
    }
  }

  Future<T> executeRawQuery<T>(
    Query<T> query,
  ) async {
    return await _requester.executeQuery(query);
  }

  Stream<QueryResult<T>> executeRawSubscription<T>(
    Query<T> query,
  ) {
    return _requester.executeSubscription(query);
  }

  Future<void> _requireValidAuth() async {
    if (!await isAuthorized()) {
      throw LightsparkAuthException(
          "You must be logged in to perform this action.");
    }
  }
}
