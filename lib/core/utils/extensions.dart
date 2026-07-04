import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Extension methods on BuildContext for quick theme/media access
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Extension methods on DateTime
extension DateExtensions on DateTime {
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  bool isSameMonth(DateTime other) => year == other.year && month == other.month;

  String toDisplayDate() => DateFormat('MMM dd, yyyy').format(this);
  String toMonthYear() => DateFormat('MMMM yyyy').format(this);
  String toShortDate() => DateFormat('MMM dd').format(this);
  String toIso() => toIso8601String();
}

/// Extension methods on double for currency formatting
extension DoubleExtensions on double {
  String toCurrency(String symbol) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '$symbol${formatter.format(this)}';
  }

  String toCompact(String symbol) {
    if (this >= 1000000) return '$symbol${(this / 1000000).toStringAsFixed(1)}M';
    if (this >= 1000) return '$symbol${(this / 1000).toStringAsFixed(1)}K';
    return '$symbol${toStringAsFixed(2)}';
  }
}

/// Extension on Color for opacity shorthand
extension ColorExtensions on Color {
  Color withValues({double? alpha}) => withOpacity(alpha ?? opacity);
}
