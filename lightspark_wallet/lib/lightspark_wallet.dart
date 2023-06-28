
import 'lightspark_wallet_platform_interface.dart';

export 'src/lightspark_wallet_client.dart' show LightsparkWalletClient;
export 'src/requester/requester.dart' show Requester;
export 'src/requester/query.dart' show Query;
export 'src/crypto/crypto.dart' show getNonce;

class LightsparkWallet {
  Future<String?> getPlatformVersion() {
    return LightsparkWalletPlatform.instance.getPlatformVersion();
  }
}
