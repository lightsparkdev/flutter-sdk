import 'package:flutter_test/flutter_test.dart';
import 'package:lightspark_wallet/lightspark_wallet.dart';
import 'package:lightspark_wallet/lightspark_wallet_platform_interface.dart';
import 'package:lightspark_wallet/lightspark_wallet_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockLightsparkWalletPlatform
    with MockPlatformInterfaceMixin
    implements LightsparkWalletPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final LightsparkWalletPlatform initialPlatform =
      LightsparkWalletPlatform.instance;

  test('$MethodChannelLightsparkWallet is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelLightsparkWallet>());
  });

  test('getPlatformVersion', () async {
    LightsparkWallet lightsparkWalletPlugin = LightsparkWallet();
    MockLightsparkWalletPlatform fakePlatform = MockLightsparkWalletPlatform();
    LightsparkWalletPlatform.instance = fakePlatform;

    expect(await lightsparkWalletPlugin.getPlatformVersion(), '42');
  });
}
