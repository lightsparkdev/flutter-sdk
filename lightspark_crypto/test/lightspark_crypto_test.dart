import 'dart:convert';
import 'dart:typed_data';

import 'package:bip32/bip32.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex/hex.dart';

import 'package:lightspark_crypto/lightspark_crypto.dart';

void main() {
  test('test key derivation', () {
    const seedHexString = "000102030405060708090a0b0c0d0e0f";
    final seedBytes = Uint8List.fromList(HEX.decode(seedHexString));
    final seed = Seed(seedBytes);
    final signer = LightsparkSigner.fromSeed(seed);
    final xprv = signer.deriveKey("m");
    final xprvString = xprv.toBase58();
    const expectedString =
        "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi";
    expect(xprvString, expectedString);

    final xprv2 = signer.deriveKey("m/0'");
    final xprvString2 = xprv2.toBase58();
    const expectedString2 =
        "xprv9uHRZZhk6KAJC1avXpDAp4MDc3sQKNxDiPvvkX8Br5ngLNv1TxvUxt4cV1rGL5hj6KCesnDYUhd7oWgT11eZG7XnxHrnYeSvkzY7d2bhkJ7";
    expect(xprvString2, expectedString2);
  });

  test('test public key', () {
    const seedHexString = "000102030405060708090a0b0c0d0e0f";
    final seedBytes = Uint8List.fromList(HEX.decode(seedHexString));
    final seed = Seed(seedBytes);
    final signer = LightsparkSigner.fromSeed(seed);
    final publicKeyString = signer.derivePublicKey("m");
    const expectedString =
        "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8";
    expect(publicKeyString, expectedString);

    final publicKeyString2 = signer.derivePublicKey("m/0'");
    const expectedString2 =
        "xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw";
    expect(publicKeyString2, expectedString2);
  });

  test('test sign', () {
    const seedHexString = "000102030405060708090a0b0c0d0e0f";
    final seedBytes = Uint8List.fromList(HEX.decode(seedHexString));
    final seed = Seed(seedBytes);
    final signer = LightsparkSigner.fromSeed(seed);

    const publicKeyString =
        "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8";

    final xprv = signer.deriveKey("m");
    expect(xprv.neutered().toBase58(), publicKeyString);
    final verificationKey = xprv.neutered();

    const message = "Hello, world!Hello, world!Hello,";
    final messageBytes = utf8.encoder.convert(message);
    final signatureBytes = signer.deriveKeyAndSign("m", messageBytes);
    expect(verificationKey.verify(messageBytes, signatureBytes), true);
  });

  test('test tweak', () {
    const baseHexString =
        "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f";
    final baseBytes = Uint8List.fromList(HEX.decode(baseHexString));

    const mulTweak =
        "efbf7ba5a074276701798376950a64a90f698997cce0dff4d24a6d2785d20963";
    final mulTweakBytes = Uint8List.fromList(HEX.decode(mulTweak));

    const addTweak =
        "8be02a96a97b9a3c1c9f59ebb718401128b72ec009d85ee1656319b52319b8ce";
    final addTweakBytes = Uint8List.fromList(HEX.decode(addTweak));

    final signer = LightsparkSigner.fromSeed(Seed(baseBytes));
    final key = signer.tweakKey(baseBytes, addTweakBytes, mulTweakBytes);

    const resultHex =
        "d09ffff62ddb2297ab000cc85bcb4283fdeb6aa052affbc9dddcf33b61078110";
    final resultBytes = Uint8List.fromList(HEX.decode(resultHex));
    expect(key.privateKey, resultBytes);
  });

  test('test ecdh', () {
    const seed1HexString = "000102030405060708090a0b0c0d0e0f";
    final seed1Bytes = Uint8List.fromList(HEX.decode(seed1HexString));
    final seed1 = Seed(seed1Bytes);

    const seed2HexString =
        "fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542";
    final seed2Bytes = Uint8List.fromList(HEX.decode(seed2HexString));
    final seed2 = Seed(seed2Bytes);

    final signer1 = LightsparkSigner.fromSeed(seed1);
    final signer2 = LightsparkSigner.fromSeed(seed2);
    final secret1 = signer1.ecdh(
      "m",
      BIP32.fromBase58(signer2.derivePublicKey("m")).publicKey,
    );
    final secret2 = signer2.ecdh(
      "m",
      BIP32.fromBase58(signer1.derivePublicKey("m")).publicKey,
    );
    expect(secret1, secret2);
  });
}
