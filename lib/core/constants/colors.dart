import 'package:flutter/material.dart';

/// App-wide color constants for Adna
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors
  static const Color primary = Color(0xFF0f4e9d); // Adna Blue
  static const Color primaryLight = Color(0xFF1a73e8);
  static const Color primaryDark = Color(0xFF0a3d7a);

  // Secondary Colors
  static const Color secondary = Color(0xFF1a73e8);
  static const Color secondaryLight = Color(0xFF4285f4);
  static const Color secondaryDark = Color(0xFF1557b0);

  // Status Colors
  static const Color success = Color(0xFF34A853);
  static const Color successLight = Color(0xFF5bb974);
  static const Color warning = Color(0xFFFBBC04);
  static const Color warningLight = Color(0xFFfcc535);
  static const Color error = Color(0xFFEA4335);
  static const Color errorLight = Color(0xFFef6c61);
  static const Color info = Color(0xFF1a73e8);

  // Background Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color surfaceLight = Color(0xFFFAFAFA);

  // Text Colors
  static const Color textPrimary = Color(0xFF202124);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color textTertiary = Color(0xFF9AA0A6);
  static const Color textDisabled = Color(0xFF9AA0A6);
  static const Color textHint = Color(0xFFBDC1C6);

  // Border Colors
  static const Color border = Color(0xFFDADCE0);
  static const Color borderLight = Color(0xFFE8EAED);
  static const Color borderDark = Color(0xFFBDC1C6);

  // Crypto Colors
  static const Color bitcoin = Color(0xFFF7931A);
  static const Color usdt = Color(0xFF26A17B);
  static const Color usdc = Color(0xFF2775CA);

  // Overlay Colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // White & Black
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}
