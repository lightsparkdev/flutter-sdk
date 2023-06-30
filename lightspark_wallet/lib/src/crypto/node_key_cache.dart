import 'package:fast_rsa/fast_rsa.dart';

class NodeKeyCache {
  KeyPair? _keyPair;

  void setKeyPair(KeyPair keyPair) {
    _keyPair = keyPair;
  }

  KeyPair? getKeyPair() {
    return _keyPair;
  }

  clearKeyPair() {
    _keyPair = null;
  }
}