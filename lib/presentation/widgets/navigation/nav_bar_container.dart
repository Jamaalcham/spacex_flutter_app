import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/utils/colors.dart';

/// Reusable navigation bar container with gradient and shadow
/// 
/// Provides consistent styling for the bottom navigation bar background
/// with theme-aware gradients and shadows.
class NavBarContainer extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const NavBarContainer({
    super.key,
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: _buildGradient(),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: child,
    );
  }

  LinearGradient _buildGradient() {
    return isDark 
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E293B),
              Color(0xFF0F172A),
            ],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFF8FAFC),
            ],
          );
  }
}
