import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fixed app colors - Blue theme
class AppPrimaryColors {
  static const Color primary = Color(0xFF2F6BF4);
  static const Color light = Color(0xFF5A8FF7);
  static const Color dark = Color(0xFF1A56E0);
  static const Color onPrimary = Colors.white;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [light, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient horizontalGradient = LinearGradient(
    colors: [light, primary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.light;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  // Fixed cyan color getters
  Color get primaryColor => AppPrimaryColors.primary;
  Color get primaryLightColor => AppPrimaryColors.light;
  Color get primaryDarkColor => AppPrimaryColors.dark;
  Color get onPrimaryColor => AppPrimaryColors.onPrimary;

  // Gradient getters
  LinearGradient get primaryGradient => AppPrimaryColors.primaryGradient;
  LinearGradient get horizontalGradient => AppPrimaryColors.horizontalGradient;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    _isInitialized = true;
    notifyListeners();
  }

  // Static method to pre-load theme before app starts
  static Future<ThemeProvider> create() async {
    final provider = ThemeProvider();
    await provider._loadTheme();
    return provider;
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _themeMode == ThemeMode.dark);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, mode == ThemeMode.dark);
  }
}
