import 'dart:math';

int getNonce() {
  return Random.secure().nextInt(0x100000000);
}