import 'package:flutter/material.dart';

/// App-wide constants
class AppConstants {
  // App info
  static const String appName = 'Expense Tracker Pro';
  static const String appVersion = '1.0.0';

  // Hive box names
  static const String expenseBoxName = 'expenses';
  static const String categoryBoxName = 'categories';
  static const String budgetBoxName = 'budgets';
  static const String settingsBoxName = 'settings';

  // Settings keys
  static const String themeKey = 'isDarkMode';
  static const String currencyKey = 'currency';
  static const String userNameKey = 'userName';
  static const String onboardingKey = 'onboardingComplete';

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 600);
  static const Duration animVerySlow = Duration(milliseconds: 900);

  // Stagger delay
  static const Duration staggerDelay = Duration(milliseconds: 80);

  // Supported currencies
  static const List<Map<String, String>> currencies = [
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
    {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
    {'code': 'CAD', 'symbol': 'C\$', 'name': 'Canadian Dollar'},
    {'code': 'AUD', 'symbol': 'A\$', 'name': 'Australian Dollar'},
    {'code': 'CHF', 'symbol': 'Fr', 'name': 'Swiss Franc'},
    {'code': 'CNY', 'symbol': '¥', 'name': 'Chinese Yuan'},
    {'code': 'AED', 'symbol': 'د.إ', 'name': 'UAE Dirham'},
  ];

  // Default category data
  static const List<Map<String, dynamic>> defaultCategories = [
    {'name': 'Food & Dining', 'icon': 0xe532, 'colorIndex': 0},
    {'name': 'Transport', 'icon': 0xe1d6, 'colorIndex': 1},
    {'name': 'Shopping', 'icon': 0xe59c, 'colorIndex': 2},
    {'name': 'Entertainment', 'icon': 0xe40d, 'colorIndex': 3},
    {'name': 'Health', 'icon': 0xe3f5, 'colorIndex': 4},
    {'name': 'Education', 'icon': 0xe80c, 'colorIndex': 5},
    {'name': 'Travel', 'icon': 0xe7ef, 'colorIndex': 6},
    {'name': 'Bills', 'icon': 0xe850, 'colorIndex': 7},
    {'name': 'Investment', 'icon': 0xe6f3, 'colorIndex': 8},
    {'name': 'Other', 'icon': 0xe8b8, 'colorIndex': 9},
  ];

  // Income category icon
  static const int incomeCategoryIcon = 0xe227;

  // Max recent transactions on dashboard
  static const int dashboardRecentCount = 8;

  // Chart months to show
  static const int chartMonthsCount = 6;
}
