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