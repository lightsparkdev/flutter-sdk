import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'lightspark_wallet_platform_interface.dart';

/// An implementation of [LightsparkWalletPlatform] that uses method channels.
class MethodChannelLightsparkWallet extends LightsparkWalletPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('lightspark_wallet');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
