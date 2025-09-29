import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  // Border radius values
  static const BorderRadius cardBorderRadius = BorderRadius.all(Radius.circular(12));
  static const BorderRadius buttonBorderRadius = BorderRadius.all(Radius.circular(8));

  // Card elevation
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  // Button elevation
  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  // Input decoration
  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    filled: true,
    fillColor: AppColors.background,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: cardBorderRadius,
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: cardBorderRadius,
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: cardBorderRadius,
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: cardBorderRadius,
      borderSide: const BorderSide(color: AppColors.error),
    ),
    labelStyle: AppTextStyles.bodyMedium.withColor(AppColors.textSecondary),
    hintStyle: AppTextStyles.bodyMedium.withColor(AppColors.textHint),
  );

  // Card theme
  static CardThemeData get cardTheme => CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: cardBorderRadius,
      side: const BorderSide(color: AppColors.border, width: 1),
    ),
    color: AppColors.card,
  );

  // App bar theme
  static AppBarTheme get appBarTheme => AppBarTheme(
    backgroundColor: AppColors.primary,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: AppTextStyles.heading3.withColor(Colors.white),
    iconTheme: const IconThemeData(color: Colors.white),
  );

  // Floating action button theme
  static FloatingActionButtonThemeData get fabTheme => FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 6,
    shape: const CircleBorder(),
  );

  // Icon theme
  static IconThemeData get iconTheme => const IconThemeData(
    color: AppColors.textSecondary,
    size: 24,
  );

  // Progress indicator theme
  static ProgressIndicatorThemeData get progressIndicatorTheme => ProgressIndicatorThemeData(
    color: AppColors.primary,
    linearTrackColor: AppColors.border,
    circularTrackColor: AppColors.border,
  );

  // Light theme
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    cardTheme: cardTheme,
    appBarTheme: appBarTheme,
    floatingActionButtonTheme: fabTheme,
    iconTheme: iconTheme,
    inputDecorationTheme: inputDecorationTheme,
    progressIndicatorTheme: progressIndicatorTheme,
    textTheme: TextTheme(
      displayLarge: AppTextStyles.heading1,
      displayMedium: AppTextStyles.heading2,
      displaySmall: AppTextStyles.heading3,
      headlineMedium: AppTextStyles.heading4,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
  );

  // Dark theme
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: const Color(0xFF1A1A1A),
    cardTheme: cardTheme.copyWith(
      color: const Color(0xFF2A2A2A),
      shadowColor: Colors.black.withOpacity(0.3),
    ),
    appBarTheme: appBarTheme.copyWith(
      backgroundColor: const Color(0xFF1A1A1A),
    ),
    floatingActionButtonTheme: fabTheme,
    iconTheme: const IconThemeData(
      color: Colors.white70,
      size: 24,
    ),
    inputDecorationTheme: inputDecorationTheme.copyWith(
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: cardBorderRadius,
        borderSide: const BorderSide(color: Color(0xFF404040)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: cardBorderRadius,
        borderSide: const BorderSide(color: Color(0xFF404040)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: cardBorderRadius,
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    progressIndicatorTheme: progressIndicatorTheme,
    textTheme: TextTheme(
      displayLarge: AppTextStyles.heading1.withColor(Colors.white),
      displayMedium: AppTextStyles.heading2.withColor(Colors.white),
      displaySmall: AppTextStyles.heading3.withColor(Colors.white),
      headlineMedium: AppTextStyles.heading4.withColor(Colors.white),
      bodyLarge: AppTextStyles.bodyLarge.withColor(Colors.white70),
      bodyMedium: AppTextStyles.bodyMedium.withColor(Colors.white70),
      bodySmall: AppTextStyles.bodySmall.withColor(Colors.white60),
      labelLarge: AppTextStyles.labelLarge.withColor(Colors.white70),
      labelMedium: AppTextStyles.labelMedium.withColor(Colors.white70),
      labelSmall: AppTextStyles.labelSmall.withColor(Colors.white60),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
  );
}
