import 'lightspark_wallet_platform_interface.dart';

export 'src/lightspark_wallet_client.dart' show LightsparkWalletClient;
export 'src/requester/requester.dart' show Requester;
export 'src/requester/query.dart' show Query;
export 'src/auth/auth_provider.dart' show AuthProvider;
export 'src/auth/jwt/jwt_auth_provider.dart' show JwtAuthProvider;
export 'src/auth/jwt/jwt_storage.dart'
    show JwtStorage, InMemoryJwtStorage, SecureStorageJwtStorage;
export 'src/crypto/crypto.dart' show getNonce, generateRsaKeyPair;
export 'src/objects/objects.dart';

class LightsparkWallet {
  Future<String?> getPlatformVersion() {
    return LightsparkWalletPlatform.instance.getPlatformVersion();
  }
}
