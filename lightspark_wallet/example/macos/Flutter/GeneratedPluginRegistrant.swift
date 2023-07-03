//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import fast_rsa
import lightspark_wallet
import package_info_plus
import shared_preferences_foundation

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  FastRsaPlugin.register(with: registry.registrar(forPlugin: "FastRsaPlugin"))
  LightsparkWalletPlugin.register(with: registry.registrar(forPlugin: "LightsparkWalletPlugin"))
  FLTPackageInfoPlusPlugin.register(with: registry.registrar(forPlugin: "FLTPackageInfoPlusPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
}
