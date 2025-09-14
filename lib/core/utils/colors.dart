import 'package:flutter/material.dart';

/// SpaceX Application Color Palette - Professional Space-Themed Design System
class AppColors {
  // === MANDATORY SPACEX COLOR PALETTE ===
  
  // Primary Colors
  static const Color spaceBlue = Color(0xFF1E3A8A);        // Main actions, headers, navigation
  static const Color rocketOrange = Color(0xFFF59E0B);     // CTAs, highlights, accent elements
  static const Color missionGreen = Color(0xFF10B981);     // Success states, completed missions
  static const Color launchRed = Color(0xFFEF4444);        // Error states, failed missions
  
  // Background & Surface
  static const Color darkSpace = Color(0xFF0F172A);        // Main app background
  static const Color cardSurface = Color(0xFF1E293B);      // Cards, modals, elevated content
  static const Color purpleAccent = Color(0xFF8B5CF6);     // Special highlights, premium features
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);      // Primary text on dark backgrounds
  static const Color textSecondary = Color(0xFF94A3B8);    // Secondary text, captions
  
  // Legacy Support (for backward compatibility)
  static const Color primary = spaceBlue;
  static const Color secondary = rocketOrange;
  static const Color accent = purpleAccent;
  static const Color success = missionGreen;
  static const Color error = launchRed;
  static const Color warning = rocketOrange;
  static const Color info = spaceBlue;
  
  // Background Colors
  static const Color darkBackground = darkSpace;
  static const Color lightBackground = Color(0xFFF8FAFC);
  
  // Surface Colors
  static const Color darkSurface = cardSurface;
  static const Color lightSurface = Color(0xFFFFFFFF);
  
  // Card Colors
  static const Color darkCard = Color(0xFF334155);
  static const Color lightCard = Color(0xFFFFFFFF);
  
  // Text Colors (Legacy)
  static const Color darkText = Color(0xFF1F2937);
  static const Color lightText = textPrimary;
  static const Color secondaryText = textSecondary;
  
  // Extended Text Colors for Theme System
  static const Color darkTextPrimary = textPrimary;
  static const Color darkTextSecondary = textSecondary;
  static const Color darkTextTertiary = Color(0xFF64748B);
  static const Color lightTextPrimary = Color(0xFF1F2937);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextTertiary = Color(0xFF9CA3AF);
  
  // Additional Text Colors for Legacy Support
  static const Color textLight = textPrimary;
  static const Color textLightSecondary = textSecondary;
  
  // Border Colors
  static const Color darkBorder = Color(0xFF374151);
  static const Color lightBorder = Color(0xFFE5E7EB);
  
  // Generic Surface and Background Colors
  static const Color surface = cardSurface;
  static const Color background = darkSpace;
  
  // Space Theme Colors (Enhanced)
  static const Color cosmicBlue = spaceBlue;
  static const Color cosmicPurple = purpleAccent;
  static const Color nebulaPurple = purpleAccent;
  static const Color nebulaBlue = spaceBlue;
  static const Color stellarBlue = Color(0xFF3B82F6);
  static const Color solarYellow = rocketOrange;
  static const Color errorRed = launchRed;
  static const Color successGreen = missionGreen;
  static const Color infoBlue = spaceBlue;
  static const Color starWhite = textPrimary;
  
  // Glassmorphism Colors
  static Color glassBackground = Colors.white.withOpacity(0.1);
  static Color glassBackgroundLight = Colors.white.withOpacity(0.9);
  static Color glassBorder = Colors.white.withOpacity(0.2);
  static Color glassBorderLight = Colors.white.withOpacity(0.3);
  
  // Shimmer Colors
  static Color shimmerBase = cardSurface;
  static Color lightShimmerBase = Color(0xFFE1E5E9);
  static Color shimmerHighlight = Colors.white.withOpacity(0.1);
  static Color lightShimmerHighlight = Colors.white;
  
  // === PROFESSIONAL GRADIENT SYSTEM ===
  
  // Primary Space Gradient
  static const LinearGradient spaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      spaceBlue,
      Color(0xFF3B82F6),
      purpleAccent,
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  // Rocket Launch Gradient
  static const LinearGradient rocketGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      rocketOrange,
      launchRed,
    ],
  );
  
  // Mission Success Gradient
  static const LinearGradient missionGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      missionGreen,
      Color(0xFF059669),
    ],
  );
  
  // Deep Space Background Gradient (renamed from nebulaGradient)
  static const LinearGradient deepSpaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      darkSpace,
      cardSurface,
      Color(0xFF334155),
    ],
    stops: [0.0, 0.6, 1.0],
  );
  
  // Nebula Gradient (for backward compatibility)
  static const LinearGradient nebulaGradient = deepSpaceGradient;
  
  // Galaxy Gradient
  static const LinearGradient galaxyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      purpleAccent,
      spaceBlue,
      darkSpace,
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  // Light Space Gradient
  static const LinearGradient lightSpaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3B82F6),
      Color(0xFF8B5CF6),
      Color(0xFFF59E0B),
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  // Glassmorphism Gradients
  static LinearGradient glassDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withOpacity(0.1),
      Colors.white.withOpacity(0.05),
    ],
  );
  
  static LinearGradient glassLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withOpacity(0.9),
      Colors.white.withOpacity(0.7),
    ],
  );
  
  // === SEMANTIC COLOR SYSTEM ===
  
  // Status Colors with Opacity Variants
  static Color successLight = missionGreen.withOpacity(0.1);
  static Color errorLight = launchRed.withOpacity(0.1);
  static Color warningLight = rocketOrange.withOpacity(0.1);
  static Color infoLight = spaceBlue.withOpacity(0.1);
  
  // Interactive States
  static Color hoverOverlay = Colors.white.withOpacity(0.08);
  static Color pressedOverlay = Colors.white.withOpacity(0.12);
  static Color focusOverlay = Colors.white.withOpacity(0.16);
  
  // Shadow Colors
  static Color shadowDark = Colors.black.withOpacity(0.3);
  static Color shadowLight = Colors.grey.withOpacity(0.2);
  static Color glowBlue = spaceBlue.withOpacity(0.4);
  static Color glowOrange = rocketOrange.withOpacity(0.4);
  static Color glowGreen = missionGreen.withOpacity(0.4);

  // === SCREEN-SPECIFIC BACKGROUND SYSTEM ===
  
  /// Gets consistent background gradient with screen-specific accent overlay
  static BoxDecoration getScreenBackground({
    required bool isDark,
    AppScreenType screenType = AppScreenType.general,
  }) {
    // Base consistent gradient for all screens
    final baseGradient = isDark ? deepSpaceGradient : lightSpaceGradient;
    
    // Screen-specific accent overlay
    Color? accentColor;
    switch (screenType) {
      case AppScreenType.missions:
        accentColor = spaceBlue;
        break;
      case AppScreenType.rockets:
        accentColor = rocketOrange;
        break;
      case AppScreenType.launches:
        accentColor = launchRed;
        break;
      case AppScreenType.general:
        accentColor = null;
        break;
    }
    
    return BoxDecoration(
      gradient: baseGradient,
      // Add subtle screen-specific overlay if specified
      backgroundBlendMode: accentColor != null ? BlendMode.overlay : null,
    );
  }
  
  /// Gets screen-specific accent overlay container
  static Widget getScreenAccentOverlay({
    required bool isDark,
    required AppScreenType screenType,
    required Widget child,
  }) {
    Color? accentColor;
    switch (screenType) {
      case AppScreenType.missions:
        accentColor = spaceBlue;
        break;
      case AppScreenType.rockets:
        accentColor = rocketOrange;
        break;
      case AppScreenType.launches:
        accentColor = launchRed;
        break;
      case AppScreenType.general:
        return child;
    }
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            accentColor!.withOpacity(isDark ? 0.03 : 0.02),
            accentColor!.withOpacity(isDark ? 0.05 : 0.03),
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: child,
    );
  }
}

/// Screen types for consistent theming
enum AppScreenType {
  general,
  missions,
  rockets,
  launches,
}
