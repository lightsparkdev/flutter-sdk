import 'package:lightspark_wallet/lightspark_wallet.dart';

extension CurrencyDisplay on CurrencyUnit {
  String get shortName {
    return switch (this) {
      CurrencyUnit.BITCOIN => 'BTC',
      CurrencyUnit.MILLIBITCOIN => 'mBTC',
      CurrencyUnit.MICROBITCOIN => 'μBTC',
      CurrencyUnit.NANOBITCOIN => 'nBTC',
      CurrencyUnit.SATOSHI => 'sat',
      CurrencyUnit.MILLISATOSHI => 'msat',
      CurrencyUnit.USD => 'USD',
      CurrencyUnit.FUTURE_VALUE => '',
    };
  }

  String toTextValue(int amount) {
    return switch (this) {
      CurrencyUnit.BITCOIN => '${amount.toStringAsFixed(8)} $shortName',
      CurrencyUnit.MILLIBITCOIN => '${amount.toStringAsFixed(5)} $shortName',
      CurrencyUnit.MICROBITCOIN => '${amount.toStringAsFixed(2)} $shortName',
      CurrencyUnit.NANOBITCOIN => '${amount.toStringAsFixed(0)} $shortName',
      CurrencyUnit.SATOSHI => '${amount.toStringAsFixed(3)} $shortName',
      CurrencyUnit.MILLISATOSHI => '${amount.toStringAsFixed(0)} $shortName',
      CurrencyUnit.USD => '\$${(amount / 100).toStringAsFixed(2)} $shortName',
      CurrencyUnit.FUTURE_VALUE => '',
    };
  }
}