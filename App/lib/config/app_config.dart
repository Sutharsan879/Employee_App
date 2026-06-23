import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
}

class AppRadius {
  AppRadius._();
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const pill = 20.0;
}

class AppText {
  AppText._();
  static const titleLg = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
  );
  static const titleMd = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.25,
  );
  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );
  static const micro = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
}

class AppColors {
  AppColors._();

  static const flagGreen = Color(0xFF2E7D32);
  static const flagGreenLight = Color(0xFF43A047);
  static const flagGreenBg = Color(0xFFE8F5E9);
  static const primary = Color(0xFF1565C0);
  static const primaryDark = Color(0xFF0D47A1);
  static const primaryLight = Color(0xFF42A5F5);
  static const accent = Color(0xFF00897B);
  static const background = Color(0xFFF4F6F8);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF1C2833);
  static const textSecondary = Color(0xFF607D8B);
  static const error = Color(0xFFE53935);
  static const warning = Color(0xFFFF9800);

  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1976D2)],
  );

  static const flaggedGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
  );
}

class AppConfig {
  AppConfig._();
  static const debounceMs = 500;
  static const pageSize = 20;
  static const requestTimeoutSeconds = 30;
}
