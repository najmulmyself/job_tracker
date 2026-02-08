import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define color palette options
enum AppColorPalette {
  lime, // #a4d87b
  purple, // #a26af3
  skyBlue, // #74b2e6
  blue, // #2f6bf4
  orange, // #f54000
  forest, // Current deep green
}

extension AppColorPaletteExtension on AppColorPalette {
  Color get primaryColor {
    switch (this) {
      case AppColorPalette.lime:
        return const Color(0xFFA4D87B);
      case AppColorPalette.purple:
        return const Color(0xFFA26AF3);
      case AppColorPalette.skyBlue:
        return const Color(0xFF74B2E6);
      case AppColorPalette.blue:
        return const Color(0xFF2F6BF4);
      case AppColorPalette.orange:
        return const Color(0xFFF54000);
      case AppColorPalette.forest:
        return const Color(0xFF1B4332);
    }
  }

  Color get darkVariant {
    switch (this) {
      case AppColorPalette.lime:
        return const Color(0xFF8BC45E);
      case AppColorPalette.purple:
        return const Color(0xFF8A4FE0);
      case AppColorPalette.skyBlue:
        return const Color(0xFF5A9BD4);
      case AppColorPalette.blue:
        return const Color(0xFF1A56E0);
      case AppColorPalette.orange:
        return const Color(0xFFD63600);
      case AppColorPalette.forest:
        return const Color(0xFF163B2B);
    }
  }

  // Whether text on this color should be white or dark
  Color get onPrimaryColor {
    switch (this) {
      case AppColorPalette.lime:
        return const Color(0xFF1A1A2E); // Dark text on light green
      case AppColorPalette.purple:
      case AppColorPalette.skyBlue:
      case AppColorPalette.blue:
      case AppColorPalette.orange:
      case AppColorPalette.forest:
        return Colors.white;
    }
  }

  String get displayName {
    switch (this) {
      case AppColorPalette.lime:
        return 'Lime';
      case AppColorPalette.purple:
        return 'Purple';
      case AppColorPalette.skyBlue:
        return 'Sky Blue';
      case AppColorPalette.blue:
        return 'Blue';
      case AppColorPalette.orange:
        return 'Orange';
      case AppColorPalette.forest:
        return 'Forest';
    }
  }
}

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _colorKey = 'color_palette';

  ThemeMode _themeMode = ThemeMode.light;
  AppColorPalette _colorPalette = AppColorPalette.forest;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  AppColorPalette get colorPalette => _colorPalette;
  bool get isInitialized => _isInitialized;

  Color get primaryColor => _colorPalette.primaryColor;
  Color get primaryDarkColor => _colorPalette.darkVariant;
  Color get onPrimaryColor => _colorPalette.onPrimaryColor;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    final colorIndex = prefs.getInt(_colorKey) ?? AppColorPalette.forest.index;
    _colorPalette = AppColorPalette.values[colorIndex];

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

  Future<void> setColorPalette(AppColorPalette palette) async {
    _colorPalette = palette;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorKey, palette.index);
  }
}
