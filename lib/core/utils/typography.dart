import 'package:flutter/material.dart';

/// Typography system following user specifications
class AppTypography {
  static const String fontFamily = 'Inter';
  
  // Font sizes in sp
  static const double headlineSize = 24.0;  // Headline: 24sp
  static const double titleSize = 20.0;     // Title: 20sp
  static const double bodySize = 16.0;      // Body: 16sp
  static const double captionSize = 12.0;   // Caption: 12sp
  
  // Font weights
  static const FontWeight bold = FontWeight.w700;    // Bold
  static const FontWeight medium = FontWeight.w500;  // Medium
  static const FontWeight regular = FontWeight.w400; // Regular
  
  // Text styles for dark theme
  static const TextStyle headlineDark = TextStyle(
    fontSize: headlineSize,
    fontWeight: bold,
    fontFamily: fontFamily,
    color: Color(0xFFFFFFFF),
    height: 1.2,
  );
  
  static const TextStyle titleDark = TextStyle(
    fontSize: titleSize,
    fontWeight: medium,
    fontFamily: fontFamily,
    color: Color(0xFFFFFFFF),
    height: 1.3,
  );
  
  static const TextStyle bodyDark = TextStyle(
    fontSize: bodySize,
    fontWeight: regular,
    fontFamily: fontFamily,
    color: Color(0xFFDADFE5),
    height: 1.5,
  );
  
  static const TextStyle captionDark = TextStyle(
    fontSize: captionSize,
    fontWeight: regular,
    fontFamily: fontFamily,
    color: Color(0xFF64748B),
    height: 1.4,
  );
  
  // Text styles for light theme
  static const TextStyle headlineLight = TextStyle(
    fontSize: headlineSize,
    fontWeight: bold,
    fontFamily: fontFamily,
    color: Color(0xFF111827),
    height: 1.2,
  );
  
  static const TextStyle titleLight = TextStyle(
    fontSize: titleSize,
    fontWeight: medium,
    fontFamily: fontFamily,
    color: Color(0xFF111827),
    height: 1.3,
  );
  
  static const TextStyle bodyLight = TextStyle(
    fontSize: bodySize,
    fontWeight: regular,
    fontFamily: fontFamily,
    color: Color(0xFF202225),
    height: 1.5,
  );
  
  static const TextStyle captionLight = TextStyle(
    fontSize: captionSize,
    fontWeight: regular,
    fontFamily: fontFamily,
    color: Color(0xFF9CA3AF),
    height: 1.4,
  );
  
  // Helper method to get theme-appropriate text style
  static TextStyle getHeadline(bool isDark) => isDark ? headlineDark : headlineLight;
  static TextStyle getTitle(bool isDark) => isDark ? titleDark : titleLight;
  static TextStyle getBody(bool isDark) => isDark ? bodyDark : bodyLight;
  static TextStyle getCaption(bool isDark) => isDark ? captionDark : captionLight;
}
