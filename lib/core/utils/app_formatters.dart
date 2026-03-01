import 'package:intl/intl.dart';

/// Utility functions for currency, number formatting, and more.
abstract class AppFormatters {
  static final _percentFormat = NumberFormat.percentPattern()
    ..maximumFractionDigits = 1;

  static final _decimalFormat = NumberFormat('#,##0.##');

  /// Formats a double as a currency string: $1,500
  static String currency(double value, {String currencyCode = 'USD'}) {
    final symbol = _getCurrencySymbol(currencyCode);
    final format = NumberFormat.currency(
      name: currencyCode,
      symbol: symbol,
      decimalDigits: 0,
    );
    return format.format(value);
  }

  /// Formats a large number compactly: $1.5k, $1.2M
  static String compactCurrency(double value, {String currencyCode = 'USD'}) {
    final symbol = _getCurrencySymbol(currencyCode);
    final format = NumberFormat.compactCurrency(
      name: currencyCode,
      symbol: symbol,
      decimalDigits: 1,
    );
    return format.format(value);
  }

  /// Formats a decimal 0-1 as a percentage: 25%
  static String percent(double value) => _percentFormat.format(value);

  /// Returns a + prefixed percent string for gains: +15.4%
  static String gainPercent(double value) {
    final pct = (value * 100).toStringAsFixed(1);
    return value >= 0 ? '+$pct%' : '$pct%';
  }

  /// Abbreviates large numbers with K/M suffix: 1200 → 1.2K
  static String abbreviate(double value, {String currencyCode = 'USD'}) {
    final symbol = _getCurrencySymbol(currencyCode);
    if (value >= 1000000) {
      return '$symbol${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '$symbol${(value / 1000).toStringAsFixed(1)}k';
    }
    return '$symbol${value.toStringAsFixed(0)}';
  }

  static String _getCurrencySymbol(String code) {
    switch (code.toUpperCase()) {
      case 'EGP':
        return 'EGP ';
      case 'SAR':
        return 'SAR ';
      case 'AED':
        return 'AED ';
      case 'KWD':
        return 'KWD ';
      case 'QAR':
        return 'QAR ';
      case 'USD':
      default:
        return '\$';
    }
  }

  /// Formats hours: 1825→ 1,825 hrs
  static String hours(double value) => '${_decimalFormat.format(value)} hrs';

  /// Formats a score as integer percentage: 85 → 85%
  static String score(double value) => '${value.clamp(0, 100).toInt()}%';

  /// Ordinal suffix: 1→1st, 2→2nd etc.
  static String ordinal(int n) {
    final suffix = (n >= 11 && n <= 13)
        ? 'th'
        : switch (n % 10) {
            1 => 'st',
            2 => 'nd',
            3 => 'rd',
            _ => 'th',
          };
    return '$n$suffix';
  }
}
