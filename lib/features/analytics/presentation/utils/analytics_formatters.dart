import 'package:intl/intl.dart';

class AnalyticsFormatters {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final _compactCurrencyFormat = NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 1,
  );

  static final _numberFormat = NumberFormat.decimalPattern('en_IN');

  static String formatCurrency(num? value) {
    if (value == null) return '₹0';
    return _currencyFormat.format(value);
  }

  static String formatCompactCurrency(num? value) {
    if (value == null) return '₹0';
    return _compactCurrencyFormat.format(value);
  }

  static String formatNumber(num? value) {
    if (value == null) return '0';
    return _numberFormat.format(value);
  }

  static String formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatShortDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd/MM').format(date);
  }
}
