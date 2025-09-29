import 'package:flutter/material.dart';

class AppColors {
  // Primary agri-tech palette
  static const Color primary = Color(0xFF2E7D32); // Deep Agricultural Green
  static const Color warning = Color(0xFFFFA000); // Amber
  static const Color critical = Color(0xFFD32F2F); // Crimson
  static const Color operational = Color(0xFF00796B); // Teal

  // Surfaces
  static const Color background = Color(0xFFF8F9FA); // Light neutral
  static const Color card = Colors.white;
  static const Color glass = Color(0x80FFFFFF); // semi-transparent

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
}

class Paths {
  static String live(String deviceId) => 'live/$deviceId';
  static String alerts(String deviceId) => 'devices/$deviceId/alerts';
  static String aggregatesDaily(String deviceId, String ymd) => 'aggregates/daily/$deviceId/$ymd';
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
}

class AppElevation {
  static const double card = 0.5;
}
