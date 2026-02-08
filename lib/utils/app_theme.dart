import 'package:flutter/material.dart';
import '../models/job_application_model.dart';

class AppColors {
  // Brand Colors - Deep Forest Green + Orange Accent theme
  static const Color primaryGreen = Color(0xFF1B4332); // Deep forest green
  static const Color primaryGreenDark = Color(0xFF163B2B); // Darker shade
  static const Color primaryDark = Color(
    0xFF0D2818,
  ); // Darkest green for contrast
  static const Color accentOrange = Color(0xFFF5A623); // Orange accent
  static const Color accentOrangeDark = Color(0xFFE09000); // Darker orange

  // Legacy aliases for compatibility
  static const Color primaryBlue = primaryGreen;
  static const Color accentBlue = accentOrange;

  // Light Theme Colors (Default)
  static const Color lightBackground = Color(0xFFF8F9FA); // Soft off-white
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Dark Theme Colors - Pure dark (no blue tint)
  static const Color darkBackground = Color(0xFF0D0D0D); // Near black
  static const Color darkSurface = Color(0xFF171717); // Slightly lighter
  static const Color darkCard = Color(0xFF1C1C1C); // Card background

  // Status Colors (matching reference images)
  static const Color statusInterview = Color(0xFFB8DB80); // Green - Interview
  static const Color statusApplied = Color(
    0xFFFFB946,
  ); // Yellow/Orange - Applied
  static const Color statusRejected = Color(0xFFFF6B6B); // Red - Rejected
  static const Color statusOffer = Color(0xFF9C27B0); // Purple - Offer
  static const Color statusInterested = Color(0xFF64B5F6); // Blue - Interested

  // Text Colors - Light Theme
  static const Color lightTextPrimary = Color(0xFF1A1F2E);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextTertiary = Color(0xFF9CA3AF);

  // Text Colors - Dark Theme
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B8C8);
  static const Color darkTextTertiary = Color(0xFF6B7280);

  // Legacy support
  static const Color primary = primaryGreen;
  static const Color secondary = primaryGreenDark;
  static const Color error = statusRejected;
  static const Color onPrimary =
      Colors.white; // White text on deep green background
  static const Color onSecondary = Colors.white;

  // Get color by stage
  static Color getStageColor(ApplicationStage stage) {
    switch (stage) {
      case ApplicationStage.interested:
        return statusInterested;
      case ApplicationStage.applied:
        return statusApplied;
      case ApplicationStage.interviewCalled:
        return const Color(0xFF00BCD4); // Cyan - Called for interview
      case ApplicationStage.interviewed:
        return statusInterview; // Green - Already interviewed
      case ApplicationStage.offer:
        return statusOffer;
      case ApplicationStage.rejected:
        return statusRejected;
    }
  }

  // Get light version of stage color
  static Color getStageLightColor(ApplicationStage stage) {
    return getStageColor(stage).withOpacity(0.2);
  }
}

class AppTheme {
  // Dynamic theme methods that accept custom colors
  static ThemeData getLightTheme({
    required Color primaryColor,
    required Color primaryDarkColor,
    required Color onPrimaryColor,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: primaryDarkColor,
        surface: AppColors.lightSurface,
        error: AppColors.statusRejected,
        onPrimary: onPrimaryColor,
        onSecondary: Colors.white,
        onSurface: AppColors.lightTextPrimary,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.lightCard,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.lightTextTertiary.withOpacity(0.1),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        hintStyle: TextStyle(color: AppColors.lightTextTertiary),
        labelStyle: TextStyle(color: AppColors.lightTextSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.lightTextTertiary.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.lightTextTertiary.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.statusRejected,
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.bold,
          letterSpacing: -1,
        ),
        displayMedium: TextStyle(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        titleMedium: TextStyle(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        titleSmall: TextStyle(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        bodyLarge: TextStyle(color: AppColors.lightTextPrimary, fontSize: 16),
        bodyMedium: TextStyle(
          color: AppColors.lightTextSecondary,
          fontSize: 14,
        ),
        bodySmall: TextStyle(color: AppColors.lightTextTertiary, fontSize: 12),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightCard,
        selectedColor: primaryColor,
        labelStyle: const TextStyle(color: AppColors.lightTextPrimary),
        secondaryLabelStyle: TextStyle(color: onPrimaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: onPrimaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: AppColors.accentOrange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData getDarkTheme({
    required Color primaryColor,
    required Color primaryDarkColor,
    required Color onPrimaryColor,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryDarkColor,
        surface: AppColors.darkSurface,
        error: AppColors.statusRejected,
        onPrimary: onPrimaryColor,
        onSecondary: Colors.white,
        onSurface: AppColors.darkTextPrimary,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.darkCard,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        hintStyle: TextStyle(color: AppColors.darkTextTertiary),
        labelStyle: TextStyle(color: AppColors.darkTextSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.darkTextTertiary.withOpacity(0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.darkTextTertiary.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.statusRejected,
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.bold,
          letterSpacing: -1,
        ),
        displayMedium: TextStyle(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        titleMedium: TextStyle(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        titleSmall: TextStyle(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        bodyLarge: TextStyle(color: AppColors.darkTextPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: AppColors.darkTextSecondary, fontSize: 14),
        bodySmall: TextStyle(color: AppColors.darkTextTertiary, fontSize: 12),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedColor: primaryColor,
        labelStyle: const TextStyle(color: AppColors.darkTextPrimary),
        secondaryLabelStyle: TextStyle(color: onPrimaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: onPrimaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: AppColors.accentOrange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // Keep static themes for backward compatibility
  static ThemeData get lightTheme => getLightTheme(
    primaryColor: AppColors.primaryGreen,
    primaryDarkColor: AppColors.primaryGreenDark,
    onPrimaryColor: Colors.white,
  );

  static ThemeData get darkTheme => getDarkTheme(
    primaryColor: AppColors.primaryGreen,
    primaryDarkColor: AppColors.primaryGreenDark,
    onPrimaryColor: Colors.white,
  );
}
