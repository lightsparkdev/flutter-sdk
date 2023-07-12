# lightspark_wallet

This is the Lightspark Wallet Flutter SDK! See the example project for a demonstration of how to use it or read below to get started.

## Getting Started

To use the wallet SDK, first install it as a dependency in your app:

__NOTE__: This won't work until the first release of the SDK is published! It's not live yet :-).

```bash
flutter pub add lightspark_wallet
```

Then, import it:

```dart
import 'package:lightspark_wallet/lightspark_wallet.dart';
```

### Authentication via JWT

The current version of the SDK supports JWT authentication, which is intended for client-side use. To authenticate, you'll need to login using your lightspark account ID and
a JWT allocated for the user by your own server.

![jwt diagram](./docs-media/jwt-diagram.png)

First, you'll need to register your account public key with Lightspark. You can do this from the [Lightspark Account Settings page](https://app.lightspark.com/account#security). You'll need to provide the public key for the account you want to use to sign JWTs. You can generate a keypair using the _ES256_ algorithm using the following command:

```bash
openssl genrsa -out private.key 2048
```

This will generate a private key file called private.key. You can then generate the public key file using the following command:

```bash
openssl rsa -in private.key -pubout -out public.key
```

You can then copy the contents of the public key file into the "JWT Public Key" field on the API Tokens page. You'll also want to copy the private key into your server code (or rather in secret keystore or environment variable), so that you can use it to sign JWTs.

Next, you'll need to create a JWT for the user. You should expose an endpoint from your backend to create these tokens. For example, to create a JWT from a typescript+node server:

```typescript
import * as jwt from "jsonwebtoken";

// Create a JSON object that contains the claims for your JWT.
const claims = {
  aud: "https://api.lightspark.com",
  // Any unique identifier for the user.
  sub: "511c7eb8-9afe-4f69-989a-8d1113a33f3d",
  // True to use the test environment, false to use the production environment.
  test: true,
  iat: 1516239022,
  // Expriation time for the JWT.
  exp: 1799393363,
};

// Call the `sign()` method on the `jsonwebtoken` library, passing in the JSON object and your private key.
const token = jwt.sign(claims, "your private key");

// Now send the token back to the client so that they can use it to authenticate with the Lightspark SDK.
```

Now on the client, you can login using the JWT and your company's account ID from the account settings page:

```dart
await client.loginWithJWT(ACCOUNT_ID, jwt, SharedPreferencesJwtStorage());
```

You'll notice that this request takes a parameter which is an implementation of `JwtStorage`. This can be used to save credentials for the next time the app starts up. If you want to recover wallet credentials using saved JWT info, you can pass a JWT storage implementation to the client constructor. For example, if you've previously logged in using a `SharedPreferencesJwtStorage` implementation, you can recover the credentials at app startup like so:

```dart
import 'package:lightspark_wallet/lightspark_wallet.dart';

final jwtStorage = SharedPreferencesJwtStorage();
final client = LightsparkWalletClient(authProvider: JwtAuthProvider(jwtStorage));
```

### Deploying and initializing a wallet

![wallet state diagram](./docs-media/wallet-state-diagram.png)

When a user logs in for the first time, initially, their wallet will be in a `NOT_SETUP` status. You can identify this status by querying the current wallet:

```dart
final wallet = await client.getCurrentWallet();
if (wallet.status == WalletStatus.NOT_SETUP) {
  // The wallet is not setup, so we need to deploy it.
}
```

To deploy the wallet, you'll need to call `client.deployWallet()` and then wait for the wallet's status to update to the DEPLOYED or FAILED status. You can do this either by polling the wallet, or by subscribing to wallet updates via the helper function which subscribes to status updates.

Here's an example which polls wallet state every 2 seconds:

```dart
var wallet = await client.deployWallet();
while (
  wallet.status != WalletStatus.DEPLOYED &&
  wallet.status != WalletStatus.FAILED
) {
  await Future.delayed(const Duration(seconds: 2));
  wallet = await client.getCurrentWallet();
}

// Now the wallet is either deployed or failed.
```

Alternatively, here's an example using the helper, `deployWalletAndAwaitDeployed`:

```dart
final walletSatus = await client.deployWalletAndAwaitDeployed();
if (walletStatus == WalletStatus.DEPLOYED) {
  // The wallet is deployed!
} else {
  // The wallet failed to deploy.
}
```

Once the wallet is deployed, you can initialize it. However, first you'll need signing keys for the wallet to complete sensitive operations.

#### Key generation for the wallet

When initializing the wallet, you'll need to provide a public key for the wallet to use to sign transactions. Note that this _is not_ the same as your JWT signing key used above. It should be unique to each user's wallet. It is the responsibility of your application to safely store the keypair for the user. Losing the private key will result in the user losing access to their wallet. Currently, the wallet SDK only supports RSA-PSS keys, but we plan to support other key types in the future.

For convenience, the wallet SDK provides a `generateRsaKeyPair()` method which can be used to generate a keypair. You can then store the keys however you'd like in your application code.

```dart
import 'package:lightspark_wallet/lightspark_wallet.dart';

final keyPair = await generateRsaKeyPair();
const signingWalletPublicKey = keyPair.publicKey;
const signingWalletPrivateKey = keyPair.privateKey;

// Store the keys somewhere safe.
```

#### Initializing the wallet

Now that you've got keys, you can initialize the wallet! Just like when deploying, you can do this either by polling the wallet, or by subscribing to wallet updates via `client.initializeWalletAndAwaitReady`.

```dart
var wallet = await client.initializeWallet(
  KeyType.RSA_OAEP,
  serializedPublicKey,
  serializedPrivateKey
);
while (
  wallet.status != WalletStatus.READY &&
  wallet.status != WalletStatus.FAILED
) {
  await Future.delayed(const Duration(seconds: 2));
  wallet = await client.getCurrentWallet();
}

// Now the wallet is either ready or failed.
```

Alternatively, here's an example using the helper, `initializeWalletAndAwaitReady`:

```dart
final walletSatus = await client.initializeWalletAndAwaitReady(
  KeyType.RSA_OAEP,
  serializedPublicKey,
  serializedPrivateKey
);
if (walletStatus == WalletStatus.READY) {
  // The wallet is initialized!
} else {
  // The wallet failed to initialize.
}
```

#### Unlock the wallet and make requests

When the wallet is in the READY state, you can make requests. However, in order to complete sensitive operations like sending payments, first you'll need to unlock the wallet using the private key you generated earlier.

```dart
await client.loadWalletSigningKey(serializedPublicKey, serializedPrivateKey);
```

Now you can make requests! For example, to create an invoice:

```dart
final invoiceData = await client.createInvoice(
    100_000,
    memo: "mmmmm pizza",
);
```

or pay an invoice:

```dart
final payment = await client.payInvoice(
  /* encodedInvoice */ invoiceData.encodedPaymentRequest,
  /* maxFeesMsats */ 50_000
);
```

For more examples, check out the [integration tests](./example/integration_test/plugin_integration_test.dart) or chek out the [example app](./example/).
