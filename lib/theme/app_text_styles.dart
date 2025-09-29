import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Headings
  static TextStyle get heading1 => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    height: 1.2,
  );

  static TextStyle get heading2 => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
    height: 1.3,
  );

  static TextStyle get heading3 => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
    height: 1.3,
  );

  static TextStyle get heading4 => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
    height: 1.4,
  );

  // Body text
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
    height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
    height: 1.4,
  );

  // Labels and captions
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
    height: 1.4,
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
    height: 1.3,
  );

  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
    height: 1.3,
  );

  // Card titles
  static TextStyle get cardTitle => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
    height: 1.3,
  );

  // Metric values
  static TextStyle get metricValue => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    height: 1.2,
  );

  static TextStyle get metricUnit => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.grey[600],
    height: 1.2,
  );

  // Timestamps
  static TextStyle get timestamp => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: Colors.grey[500],
    height: 1.2,
  );

  // Button text
  static TextStyle get buttonText => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.2,
  );

  // Alert text
  static TextStyle get alertTitle => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
    height: 1.3,
  );

  static TextStyle get alertMessage => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
    height: 1.4,
  );
}

// Extension for easy color customization
extension TextStyleExtensions on TextStyle {
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle withOpacity(double opacity) => copyWith(color: color?.withOpacity(opacity));
}
