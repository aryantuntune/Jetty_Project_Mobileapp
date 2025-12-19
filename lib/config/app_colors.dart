import 'package:flutter/material.dart';

class AppColors {
  // Modern color scheme - Blue ocean theme
  static const Color primary = Color(0xFF174A6F); // Deep blue from logo
  static const Color primaryDark = Color(0xFF123A56); // Darker blue
  static const Color primaryLight = Color(0xFF00B2C6); // Teal from logo
  static const Color accent = Color(0xFF00B2C6); // Teal
  static const Color background = Color(0xFFFFFFFF); // White
  static const Color surface = Color(0xFFF2F7FF); // Light background
  static const Color error = Color(0xFFFF3B30);
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color textPrimary = Color(0xFF174A6F); // Deep blue
  static const Color textSecondary = Color(0xFF00B2C6); // Teal
  static const Color divider = Color(0xFFE5E5EA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color shimmer = Color(0xFFE3F2FD);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF174A6F), Color(0xFF00B2C6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00B2C6), Color(0xFFFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
