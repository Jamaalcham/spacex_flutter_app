import 'package:flutter/material.dart';

/// Spacing system following user specifications
class AppSpacing {
  // Spacing values in dp
  static const double xs = 4.0;   // XS: 4dp
  static const double s = 8.0;    // S: 8dp
  static const double m = 16.0;   // M: 16dp
  static const double l = 24.0;   // L: 24dp
  static const double xl = 32.0;  // XL: 32dp
  
  // Padding helpers
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingS = EdgeInsets.all(s);
  static const EdgeInsets paddingM = EdgeInsets.all(m);
  static const EdgeInsets paddingL = EdgeInsets.all(l);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  
  // Horizontal padding helpers
  static const EdgeInsets paddingHorizontalXS = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets paddingHorizontalS = EdgeInsets.symmetric(horizontal: s);
  static const EdgeInsets paddingHorizontalM = EdgeInsets.symmetric(horizontal: m);
  static const EdgeInsets paddingHorizontalL = EdgeInsets.symmetric(horizontal: l);
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(horizontal: xl);
  
  // Vertical padding helpers
  static const EdgeInsets paddingVerticalXS = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets paddingVerticalS = EdgeInsets.symmetric(vertical: s);
  static const EdgeInsets paddingVerticalM = EdgeInsets.symmetric(vertical: m);
  static const EdgeInsets paddingVerticalL = EdgeInsets.symmetric(vertical: l);
  static const EdgeInsets paddingVerticalXL = EdgeInsets.symmetric(vertical: xl);
  
  // SizedBox helpers
  static const Widget gapXS = SizedBox(width: xs, height: xs);
  static const Widget gapS = SizedBox(width: s, height: s);
  static const Widget gapM = SizedBox(width: m, height: m);
  static const Widget gapL = SizedBox(width: l, height: l);
  static const Widget gapXL = SizedBox(width: xl, height: xl);
  
  // Horizontal gaps
  static const Widget gapHorizontalXS = SizedBox(width: xs);
  static const Widget gapHorizontalS = SizedBox(width: s);
  static const Widget gapHorizontalM = SizedBox(width: m);
  static const Widget gapHorizontalL = SizedBox(width: l);
  static const Widget gapHorizontalXL = SizedBox(width: xl);
  
  // Vertical gaps
  static const Widget gapVerticalXS = SizedBox(height: xs);
  static const Widget gapVerticalS = SizedBox(height: s);
  static const Widget gapVerticalM = SizedBox(height: m);
  static const Widget gapVerticalL = SizedBox(height: l);
  static const Widget gapVerticalXL = SizedBox(height: xl);
}
