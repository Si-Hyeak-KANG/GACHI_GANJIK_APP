import 'package:flutter/material.dart';

class AppColors {
  static const Color bg = Color(0xFFFFFFFF);
  static const Color main = Color(0xFFFF6F7D);
  static const Color mainLight = Color(0xFFFFF4F5);
  static const Color textPrimary = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF666666);
  static const Color inactive = Color(0xFFD9D9D9);
  static const Color cardBg = Color(0xFFFAFAFA);

  // Gradient
  static const LinearGradient mainGradient = LinearGradient(
    colors: [mainLight, Color(0xFFFFFF0E6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
