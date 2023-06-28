import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'lightspark_wallet_method_channel.dart';

abstract class LightsparkWalletPlatform extends PlatformInterface {
  /// Constructs a LightsparkWalletPlatform.
  LightsparkWalletPlatform() : super(token: _token);

  static final Object _token = Object();

  static LightsparkWalletPlatform _instance = MethodChannelLightsparkWallet();

  /// The default instance of [LightsparkWalletPlatform] to use.
  ///
  /// Defaults to [MethodChannelLightsparkWallet].
  static LightsparkWalletPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LightsparkWalletPlatform] when
  /// they register themselves.
  static set instance(LightsparkWalletPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
