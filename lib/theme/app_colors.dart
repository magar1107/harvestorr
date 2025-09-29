import 'package:flutter/material.dart';

// Extended color palette for the harvester dashboard
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF2E7D32); // Deep Agricultural Green
  static const Color primaryLight = Color(0xFF60AD5E);
  static const Color primaryDark = Color(0xFF005005);

  // Secondary colors
  static const Color secondary = Color(0xFF7B1FA2); // Purple for gauges
  static const Color secondaryLight = Color(0xFFAE52D4);
  static const Color secondaryDark = Color(0xFF4A007D);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA000);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF2196F3);
  static const Color critical = Color(0xFFB71C1C);

  // Alert colors
  static const Color alertInfo = Color(0xFF2196F3);
  static const Color alertWarning = Color(0xFFFFA000);
  static const Color alertError = Color(0xFFD32F2F);
  static const Color alertSuccess = Color(0xFF4CAF50);

  // Neutral colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color card = Colors.white;

  // Text colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textHint = Color(0xFF64748B);

  // Border and divider
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE2E8F0);

  // Glass effect
  static const Color glass = Color(0x80FFFFFF);

  // Gradient colors for gauges
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFFA000), Color(0xFFFFC107)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFD32F2F), Color(0xFFF44336)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF7B1FA2), Color(0xFF9C27B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
