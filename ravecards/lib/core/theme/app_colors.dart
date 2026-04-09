// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF06000F);
  static const Color purple = Color(0xFFB300FF);
  static const Color green = Color(0xFF39FF14);
  static const Color white = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFF0D001A);
  static const Color error = Color(0xFFFF4444);
  static const Color textSecondary = Color(0xFF888888);

  static const LinearGradient purpleGlow = LinearGradient(
    colors: [Color(0x26B300FF), Color(0x00B300FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
