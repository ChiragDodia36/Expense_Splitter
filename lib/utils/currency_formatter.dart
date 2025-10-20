import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _compactFormat = NumberFormat.compactCurrency(
    symbol: '\$',
    decimalDigits: 0,
  );

  /// Format amount as currency (e.g., $123.45)
  static String format(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Format amount in compact form (e.g., $1.2K)
  static String formatCompact(double amount) {
    return _compactFormat.format(amount);
  }

  /// Format amount without symbol (e.g., 123.45)
  static String formatWithoutSymbol(double amount) {
    return amount.toStringAsFixed(2);
  }

  /// Parse string to double
  static double parse(String text) {
    try {
      // Remove currency symbols and commas
      final cleaned = text.replaceAll(RegExp(r'[^\d.]'), '');
      return double.parse(cleaned);
    } catch (e) {
      return 0.0;
    }
  }

  /// Format date
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format date with time
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  /// Format date as short (e.g., 12/31)
  static String formatDateShort(DateTime date) {
    return DateFormat('MM/dd').format(date);
  }

  /// Format relative date (e.g., Today, Yesterday, Dec 25)
  static String formatDateRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else if (now.difference(dateOnly).inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }
}

