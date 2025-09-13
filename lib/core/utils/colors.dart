import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors - Updated to match specifications
  static const Color primary = Color(0xFF1E3A8A); // Space Blue
  static const Color secondary = Color(0xFFF59E0B); // Rocket Orange
  static const Color success = Color(0xFF10B981); // Mission Green
  static const Color error = Color(0xFFEF4444); // Launch Red
  static const Color background = Color(0xFF0F172A); // Dark Space
  static const Color surface = Color(0xFF1E293B); // Card Surface
  static const Color accent = Color(0xFF8B5CF6); // Purple Accent
  
  // Legacy colors for backward compatibility
  static const Color spaceBlue = Color(0xFF0B1426);
  static const Color deepSpace = Color(0xFF0F172A);
  static const Color cosmicBlue = Color(0xFF1E3A8A);
  static const Color stellarBlue = Color(0xFF3B82F6);
  static const Color nebulaBlue = Color(0xFF60A5FA);
  
  // Accent Colors
  static const Color rocketOrange = Color(0xFFF59E0B);
  static const Color flameOrange = Color(0xFFFF8500);
  static const Color solarYellow = Color(0xFFFBBF24);
  static const Color cosmicPurple = Color(0xFF8B5CF6);
  static const Color galaxyPurple = Color(0xAA6C63FF);
  
  // Status Colors - Updated
  static const Color successGreen = Color(0xFF10B981);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color infoBlue = Color(0xFF1E3A8A);
  
  // Dark Theme Colors - Updated
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF475569);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);
  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightText = Color(0xFF1F2937);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF1F2937);
  static const Color textLightSecondary = Color(0xFF6B7280);
  static const Color lightTextTertiary = Color(0xFF64748B);
  
  // Gradients
  static const LinearGradient spaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0B1426),
      Color(0xFF1E3A8A),
      Color(0xFF3B82F6),
      Color(0xFF8B5CF6),
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );
  
  static const LinearGradient rocketGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFF6B35),
      Color(0xFFFF8500),
      Color(0xFFFBBF24),
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient nebulaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8B5CF6),
      Color(0xFF6366F1),
      Color(0xFF3B82F6),
    ],
  );
  
  static const LinearGradient galaxyGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF1E3A8A),
      Color(0xFF7C3AED),
      Color(0xFFEC4899),
    ],
  );
  
  static const LinearGradient lightSpaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE0F2FE),
      Color(0xFFBAE6FD),
      Color(0xFF7DD3FC),
    ],
  );
  
  // Shimmer Colors
  static const Color shimmerBase = Color(0xFF334155);
  static const Color shimmerHighlight = Color(0xFF475569);
  static const Color lightShimmerBase = Color(0xFFE2E8F0);
  static const Color lightShimmerHighlight = Color(0xFFF1F5F9);
  
  // Glass Effect Colors
  static Color glassBackground = Colors.white.withOpacity(0.1);
  static Color glassBackgroundLight = Colors.black.withOpacity(0.05);
  static Color glassBorder = Colors.white.withOpacity(0.2);
  static Color glassBorderLight = Colors.black.withOpacity(0.1);
  
  // Legacy support (for backward compatibility)
  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecondary;
}
