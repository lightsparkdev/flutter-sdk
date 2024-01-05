import 'dart:math';

import 'package:fast_rsa/fast_rsa.dart';

int getNonce() {
  return Random.secure().nextInt(0x100000000);
}

Future<KeyPair> generateRsaKeyPair() {
  return RSA.generate(4096);
}

String stripPemTags(String keyString) {
  return keyString.replaceAll(RegExp(r'-----.*-----'), '');
}

Future<String> signRsa(String privateKey, String message) {
  return RSA.signPSS(message, Hash.SHA256, SaltLength.AUTO, privateKey);
}
