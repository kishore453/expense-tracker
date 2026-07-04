import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';

Box get _settingsBox => Hive.box(AppConstants.settingsBoxName);

// ---------------------------------------------------------------------------
// Dark Mode
// ---------------------------------------------------------------------------

final isDarkModeProvider = StateNotifierProvider<DarkModeNotifier, bool>((ref) {
  final isDark = _settingsBox.get(AppConstants.themeKey, defaultValue: false) as bool;
  return DarkModeNotifier(isDark);
});

class DarkModeNotifier extends StateNotifier<bool> {
  DarkModeNotifier(super.state);

  void toggle() {
    state = !state;
    _settingsBox.put(AppConstants.themeKey, state);
  }

  void set(bool value) {
    state = value;
    _settingsBox.put(AppConstants.themeKey, value);
  }
}

// ---------------------------------------------------------------------------
// Currency
// ---------------------------------------------------------------------------

final currencyProvider = StateNotifierProvider<CurrencyNotifier, Map<String, String>>((ref) {
  final code = _settingsBox.get(AppConstants.currencyKey, defaultValue: 'INR') as String;
  final currency = AppConstants.currencies.firstWhere(
    (c) => c['code'] == code,
    orElse: () => AppConstants.currencies[3], // INR default
  );
  return CurrencyNotifier(currency);
});

class CurrencyNotifier extends StateNotifier<Map<String, String>> {
  CurrencyNotifier(super.state);

  void setCurrency(Map<String, String> currency) {
    state = currency;
    _settingsBox.put(AppConstants.currencyKey, currency['code']);
  }
}

final currencySymbolProvider = Provider<String>((ref) {
  return ref.watch(currencyProvider)['symbol'] ?? '₹';
});

// ---------------------------------------------------------------------------
// User Name
// ---------------------------------------------------------------------------

final userNameProvider = StateNotifierProvider<UserNameNotifier, String>((ref) {
  final name = _settingsBox.get(AppConstants.userNameKey, defaultValue: 'User') as String;
  return UserNameNotifier(name);
});

class UserNameNotifier extends StateNotifier<String> {
  UserNameNotifier(super.state);

  void setName(String name) {
    state = name;
    _settingsBox.put(AppConstants.userNameKey, name);
  }
}

// ---------------------------------------------------------------------------
// Bottom Nav Index
// ---------------------------------------------------------------------------

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
