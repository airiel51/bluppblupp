class CurrencyInfo {
  final String code;
  final String name;
  final String symbol;
  final String flag;
  final double rateToMYR; // 1 MYR = X Foreign Currency

  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
    required this.rateToMYR,
  });
}

class CurrencyManager {
  static const List<CurrencyInfo> supportedCurrencies = [
    CurrencyInfo(code: 'MYR', name: 'Malaysian Ringgit', symbol: 'RM', flag: '🇲🇾', rateToMYR: 1.0),
    CurrencyInfo(code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp', flag: '🇮🇩', rateToMYR: 3550.0),
    CurrencyInfo(code: 'SGD', name: 'Singapore Dollar', symbol: 'S\$', flag: '🇸🇬', rateToMYR: 0.302),
    CurrencyInfo(code: 'USD', name: 'US Dollar', symbol: '\$', flag: '🇺🇸', rateToMYR: 0.226),
    CurrencyInfo(code: 'EUR', name: 'Euro', symbol: '€', flag: '🇪🇺', rateToMYR: 0.208),
    CurrencyInfo(code: 'GBP', name: 'British Pound', symbol: '£', flag: '🇬🇧', rateToMYR: 0.174),
    CurrencyInfo(code: 'THB', name: 'Thai Baht', symbol: '฿', flag: '🇹🇭', rateToMYR: 7.72),
    CurrencyInfo(code: 'JPY', name: 'Japanese Yen', symbol: '¥', flag: '🇯🇵', rateToMYR: 34.5),
  ];

  static CurrencyInfo getCurrency(String code) {
    return supportedCurrencies.firstWhere(
      (c) => c.code.toUpperCase() == code.toUpperCase(),
      orElse: () => supportedCurrencies.first,
    );
  }

  /// Converts an amount from [fromCode] to [toCode]
  static double convert({
    required double amount,
    required String fromCode,
    required String toCode,
  }) {
    if (fromCode.toUpperCase() == toCode.toUpperCase()) return amount;

    final fromCurrency = getCurrency(fromCode);
    final toCurrency = getCurrency(toCode);

    // Convert to MYR first (as intermediate pivot), then to target
    // amount in MYR = amount / fromCurrency.rateToMYR
    final amountInMYR = amount / fromCurrency.rateToMYR;
    final converted = amountInMYR * toCurrency.rateToMYR;
    return converted;
  }

  /// Format an amount using a currency code's symbol
  static String format(double amount, String currencyCode) {
    final currency = getCurrency(currencyCode);
    final isNegative = amount < 0;
    final absAmount = amount.abs();

    // IDR and JPY typically don't show cents
    final isZeroDecimal = currency.code == 'IDR' || currency.code == 'JPY';
    final parts = absAmount.toStringAsFixed(isZeroDecimal ? 0 : 2).split('.');
    final integerPart = parts[0];

    final buffer = StringBuffer();
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(integerPart[i]);
    }

    final formatted = isZeroDecimal
        ? '${currency.symbol} ${buffer.toString()}'
        : '${currency.symbol} ${buffer.toString()}.${parts[1]}';

    return isNegative ? '-$formatted' : formatted;
  }
}
