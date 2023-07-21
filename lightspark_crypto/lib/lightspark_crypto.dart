library lightspark_crypto;

import 'dart:typed_data';

import 'package:bip32/bip32.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:pointycastle/export.dart';

final secp256k1 = ECCurve_secp256k1();

class Seed {
  final Uint8List _bytes;

  Seed(this._bytes);

  Seed.fromMnemonic(Mnemonic mnemonic)
      : _bytes = bip39.mnemonicToSeed(mnemonic.phrase);

  Uint8List get bytes => _bytes;
}

class Mnemonic {
  final String _phrase;

  Mnemonic(this._phrase);

  Mnemonic.generate() : _phrase = bip39.generateMnemonic();

  Mnemonic.fromPhrase(String phrase) : _phrase = phrase;

  String get phrase => _phrase;
}

class LightsparkSigner {
  final BIP32 _bip32;

  LightsparkSigner.fromSeed(Seed seed) : _bip32 = BIP32.fromSeed(seed.bytes);

  LightsparkSigner.fromMnemonic(Mnemonic mnemonic)
      : _bip32 = BIP32.fromSeed(bip39.mnemonicToSeed(mnemonic.phrase));

  LightsparkSigner.fromPhrase(String phrase)
      : _bip32 = BIP32.fromSeed(bip39.mnemonicToSeed(phrase));

  String derivePublicKey(String derivationPath) =>
      deriveKey(derivationPath).neutered().toBase58();

  Uint8List deriveKeyAndSign(
    String derivationPath,
    Uint8List message, {
    Uint8List? addTweak,
    Uint8List? mulTweak,
  }) {
    var key = deriveKey(derivationPath);
    if (addTweak != null && mulTweak != null) {
      key = tweakKey(key.privateKey!, addTweak, mulTweak);
    }
    return key.sign(message);
  }

  Uint8List ecdh(String derivationPath, Uint8List publicKey) {
    final key = deriveKey(derivationPath);
    final ecPrivateKey = ECPrivateKey(
      _bigIntfromBuffer(key.privateKey!),
      secp256k1,
    );
    final ecdh = ECDHBasicAgreement()..init(ecPrivateKey);
    final ecPublicKey =
        ECPublicKey(secp256k1.curve.decodePoint(publicKey), secp256k1);

    return _encodeBigInt(ecdh.calculateAgreement(ecPublicKey));
  }

  BIP32 deriveKey(String derivationPath) {
    if (derivationPath == 'm') return _bip32;
    return _bip32.derivePath(derivationPath);
  }

  BIP32 tweakKey(Uint8List privateKey, Uint8List addTweak, Uint8List mulTweak) {
    final multScaler = _bigIntfromBuffer(mulTweak);
    final multipliedKey =
        (_bigIntfromBuffer(privateKey) * multScaler) % secp256k1.n;

    Uint8List addedKey = _encodeBigInt(
        (multipliedKey + _bigIntfromBuffer(addTweak)) % secp256k1.n);

    if (addedKey.length < 32) {
      Uint8List padLeadingZero = Uint8List(32 - addedKey.length);
      addedKey = Uint8List.fromList(padLeadingZero + addedKey);
    }

    return BIP32.fromPrivateKey(addedKey, _bip32.chainCode, _bip32.network);
  }
}

BigInt _bigIntfromBuffer(Uint8List bytes) {
  BigInt result = BigInt.from(0);
  for (int i = 0; i < bytes.length; i++) {
    result += BigInt.from(bytes[bytes.length - i - 1]) << (8 * i);
  }
  return result;
}

Uint8List _encodeBigInt(BigInt number) {
  final negativeFlag = BigInt.from(0x80);
  final byteMask = BigInt.from(0xff);
  int needsPaddingByte;
  int rawSize;

  if (number > BigInt.zero) {
    rawSize = (number.bitLength + 7) >> 3;
    needsPaddingByte =
        ((number >> (rawSize - 1) * 8) & negativeFlag) == negativeFlag ? 1 : 0;

    if (rawSize < 32) {
      needsPaddingByte = 1;
    }
  } else {
    needsPaddingByte = 0;
    rawSize = (number.bitLength + 8) >> 3;
  }

  final size = rawSize < 32 ? rawSize + needsPaddingByte : rawSize;
  var result = Uint8List(size);
  for (int i = 0; i < size; i++) {
    result[size - i - 1] = (number & byteMask).toInt();
    number = number >> 8;
  }
  return result;
}
