import 'package:lightspark_wallet/lightspark_wallet.dart';

extension CurrencyDisplay on CurrencyUnit {
  String get shortName {
    return switch (this) {
      CurrencyUnit.BITCOIN => 'BTC',
      CurrencyUnit.MILLIBITCOIN => 'mBTC',
      CurrencyUnit.MICROBITCOIN => 'μBTC',
      CurrencyUnit.NANOBITCOIN => 'nBTC',
      CurrencyUnit.SATOSHI => 'SAT',
      CurrencyUnit.MILLISATOSHI => 'mSAT',
      CurrencyUnit.USD => 'USD',
      CurrencyUnit.FUTURE_VALUE => '',
    };
  }

  String toTextValue(int amount) {
    return switch (this) {
      CurrencyUnit.BITCOIN => '${amount.toStringAsFixed(6).addCommas()} $shortName',
      CurrencyUnit.MILLIBITCOIN => '${amount.toStringAsFixed(0).addCommas()} $shortName',
      CurrencyUnit.MICROBITCOIN => '${amount.toStringAsFixed(0).addCommas()} $shortName',
      CurrencyUnit.NANOBITCOIN => '${amount.toStringAsFixed(0).addCommas()} $shortName',
      CurrencyUnit.SATOSHI => '${amount.toStringAsFixed(0).addCommas()} $shortName',
      CurrencyUnit.MILLISATOSHI => '${amount.toStringAsFixed(0).addCommas()} $shortName',
      CurrencyUnit.USD => '\$${(amount / 100).toStringAsFixed(2).addCommas()} $shortName',
      CurrencyUnit.FUTURE_VALUE => '',
    };
  }

  double toSats(int amount) {
    return switch (this) {
      CurrencyUnit.BITCOIN => amount * 100000000.0,
      CurrencyUnit.MILLIBITCOIN => amount * 100000.0,
      CurrencyUnit.MICROBITCOIN => amount * 100.0,
      CurrencyUnit.NANOBITCOIN => amount * 0.1,
      CurrencyUnit.SATOSHI => amount.toDouble(),
      CurrencyUnit.MILLISATOSHI => amount / 1000,
      _ => throw Exception('Cannot convert from $this to sats.'),
    };
  }
}

extension on String {
  String addCommas() {
    final parts = split('.');
    final whole = parts[0];
    final decimal = parts.length > 1 ? parts[1] : '';
    final wholeWithCommas = whole.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},', 
    );
    return '$wholeWithCommas${decimal.isNotEmpty ? '.$decimal' : ''}';
  }
}