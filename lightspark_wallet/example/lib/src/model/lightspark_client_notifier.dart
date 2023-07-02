import 'package:flutter/foundation.dart';
import 'package:lightspark_wallet/lightspark_wallet.dart';

class LightsparkClientNotifier extends ValueNotifier<LightsparkWalletClient> {
  LightsparkClientNotifier(LightsparkWalletClient value) : super(value);
}