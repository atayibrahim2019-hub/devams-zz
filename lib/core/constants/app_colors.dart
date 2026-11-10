import 'package:flutter/material.dart';

class AppColors {
  // Brand / Primary Colors (Electric Blue & Midnight Indigo from reference image)
  static const Color primary = Color(0xFF4361EE);
  static const Color primaryLight = Color(0xFF6C8AFF);
  static const Color primaryDark = Color(0xFF2B3A8C);
  static const Color accent = Color(0xFF4CC9F0); // Vibrant Ice Blue

  // Status & Action Colors
  static const Color danger = Color(0xFFFF5A5F); // Vibrant Coral Red (Action button in photo)
  static const Color coralRed = Color(0xFFFF5A5F);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Dark / Midnight Navy Theme Palette (Exact colors from photo)
  static const Color darkBg = Color(0xFF0A1128); // Deep midnight navy background
  static const Color darkSurface = Color(0xFF101935);
  static const Color darkCard = Color(0xFF16224F); // Indigo navy card
  static const Color darkBorder = Color(0xFF26376D);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF8FA3CF);
  static const Color darkPillBg = Color(0xFF27386E); // Pill badge (Klinik badge in photo)

  // Header Banner Gradient
  static const List<Color> headerGradient = [
    Color(0xFF4361EE),
    Color(0xFF3F37C9),
    Color(0xFF3A0CA3),
  ];

  // Secondary Card Gradient
  static const List<Color> cardGradient = [
    Color(0xFF1A285A),
    Color(0xFF141F47),
  ];

  // Light Theme Palette
  static const Color lightBg = Color(0xFFF4F6FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFDCE3F1);
  static const Color lightTextPrimary = Color(0xFF0A1128);
  static const Color lightTextSecondary = Color(0xFF627394);
  static const Color lightPillBg = Color(0xFFE8EEFD);
}
