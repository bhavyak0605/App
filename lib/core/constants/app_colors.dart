import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF6366F1);       // Premium Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFFF97316);     // Sunset Orange
  static const Color accent = Color(0xFF10B981);        // Emerald Green (For ratings/success)

  // Light Mode Colors
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color onBackgroundLight = Color(0xFF0F172A); // Slate 900
  static const Color onSurfaceLight = Color(0xFF1E293B);    // Slate 800
  static const Color borderLight = Color(0xFFE2E8F0);       // Slate 200
  static const Color textMutedLight = Color(0xFF64748B);    // Slate 500

  // Dark Mode Colors
  static const Color backgroundDark = Color(0xFF0F172A);  // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B);     // Slate 800
  static const Color onBackgroundDark = Color(0xFFF8FAFC);  // Slate 50
  static const Color onSurfaceDark = Color(0xFFF1F5F9);     // Slate 100
  static const Color borderDark = Color(0xFF334155);        // Slate 700
  static const Color textMutedDark = Color(0xFF94A3B8);     // Slate 400

  // Common UI Colors
  static const Color starRating = Color(0xFFFBBF24);      // Amber rating star
  static const Color error = Color(0xFFEF4444);           // Red 500
  static const Color success = Color(0xFF10B981);         // Emerald 500
  static const Color info = Color(0xFF3B82F6);            // Blue 500
  static const Color glassOverlay = Color(0x1A000000);    // Translucent black overlay
}
