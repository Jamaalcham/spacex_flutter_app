import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/utils/colors.dart';
import '../../../core/utils/animations.dart';
import 'animated_card.dart';

/// Modern glassmorphism card widget with consistent space-themed styling and animations
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final List<Color>? gradientColors;
  final bool isDark;
  final VoidCallback? onTap;
  final double? elevation;
  final Duration? animationDelay;
  final bool enableHoverAnimation;

  const ModernCard({
    Key? key,
    required this.child,
    required this.isDark,
    this.margin,
    this.padding,
    this.borderRadius,
    this.gradientColors,
    this.onTap,
    this.elevation,
    this.animationDelay,
    this.enableHoverAnimation = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      child: AnimatedSpaceButton(
        onTap: onTap,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: padding ?? EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors ?? (isDark
                    ? [
                        Colors.white.withValues(alpha:0.1),
                        Colors.white.withValues(alpha:0.05),
                      ]
                    : [
                        Colors.white.withValues(alpha:0.9),
                        Colors.white.withValues(alpha:0.7),
                      ]),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(borderRadius ?? 16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha:0.2)
                    : Colors.white.withValues(alpha:0.8),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha:0.3)
                      : Colors.grey.withValues(alpha:0.2),
                  blurRadius: elevation ?? 15,
                  spreadRadius: 0,
                  offset: Offset(0, elevation != null ? elevation! / 2 : 8),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );

    // Return with entrance animation if delay is specified
    if (animationDelay != null) {
      return AnimatedCard(
        delay: animationDelay!,
        enableHover: enableHoverAnimation,
        onTap: onTap,
        child: cardContent,
      );
    }
    
    return cardContent;
  }
}

/// Modern icon container with gradient background
class ModernIconContainer extends StatelessWidget {
  final IconData icon;
  final List<Color> gradientColors;
  final double? size;
  final double? iconSize;

  const ModernIconContainer({
    Key? key,
    required this.icon,
    required this.gradientColors,
    this.size,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size ?? 3.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha:0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: iconSize ?? 8.w,
      ),
    );
  }
}

/// Modern button with glassmorphism effect
class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final List<Color>? gradientColors;
  final bool isDark;
  final IconData? icon;
  final double? width;
  final double? height;

  const ModernButton({
    Key? key,
    required this.text,
    required this.isDark,
    this.onPressed,
    this.gradientColors,
    this.icon,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 12.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors ?? [
            const Color(0xFF3B82F6),
            const Color(0xFF8B5CF6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (gradientColors?.first ?? const Color(0xFF3B82F6)).withValues(alpha:0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 18.sp),
                  SizedBox(width: 2.w),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Modern search bar with glassmorphism
class ModernSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final bool isDark;
  final TextEditingController? controller;

  const ModernSearchBar({
    super.key,
    required this.hintText,
    required this.isDark,
    this.onChanged,
    this.onFilterTap,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.white.withValues(alpha:0.1),
                  Colors.white.withValues(alpha:0.05),
                ]
              : [
                  Colors.white.withValues(alpha:0.9),
                  Colors.white.withValues(alpha:0.7),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha:0.2)
              : Colors.white.withValues(alpha:0.8),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: isDark ? Colors.white60 : Colors.black54,
            size: 20.sp,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16.sp,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: 16.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 3.w),
              ),
            ),
          ),
          if (onFilterTap != null) ...[
            SizedBox(width: 3.w),
            InkWell(
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.all(2.w),
                child: Icon(
                  Icons.tune_rounded,
                  color: isDark ? Colors.white60 : Colors.black54,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Neumorphism card with inset/outset effects
class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final bool isPressed;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  const NeumorphicCard({
    Key? key,
    required this.child,
    this.isPressed = false,
    this.onTap,
    this.margin,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.all(3.w),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: padding ?? EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(borderRadius ?? 20),
            boxShadow: isPressed
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.4),
                      offset: const Offset(2, 2),
                      blurRadius: 8,
                      spreadRadius: -2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.3),
                      offset: const Offset(8, 8),
                      blurRadius: 16,
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha:0.1),
                      offset: const Offset(-8, -8),
                      blurRadius: 16,
                    ),
                  ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Floating action button with space theme
class SpaceFloatingButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final List<Color>? gradientColors;
  final double? size;

  const SpaceFloatingButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.gradientColors,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size ?? 14.w,
      height: size ?? 14.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors ?? [
            AppColors.spaceBlue,
            AppColors.purpleAccent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular((size ?? 14.w) / 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.spaceBlue.withValues(alpha:0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular((size ?? 14.w) / 2),
          child: Icon(
            icon,
            color: Colors.white,
            size: (size ?? 14.w) * 0.4,
          ),
        ),
      ),
    );
  }
}

/// Modern tab bar with glassmorphism
class ModernTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final bool isDark;

  const ModernTabBar({
    Key? key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.white.withValues(alpha:0.1),
                  Colors.white.withValues(alpha:0.05),
                ]
              : [
                  Colors.white.withValues(alpha:0.9),
                  Colors.white.withValues(alpha:0.7),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha:0.2)
              : Colors.white.withValues(alpha:0.8),
          width: 1,
        ),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == selectedIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(vertical: 3.w),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [
                            AppColors.spaceBlue,
                            AppColors.purpleAccent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.spaceBlue.withValues(alpha:0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black54),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Modern progress indicator with space theme
class SpaceProgressIndicator extends StatelessWidget {
  final double progress;
  final List<Color>? gradientColors;
  final double? height;
  final String? label;

  const SpaceProgressIndicator({
    super.key,
    required this.progress,
    this.gradientColors,
    this.height,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.w),
        ],
        Container(
          height: height ?? 1.w,
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular((height ?? 1.w) / 2),
          ),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular((height ?? 1.w) / 2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors ?? [
                        AppColors.missionGreen,
                        AppColors.rocketOrange,
                      ],
                    ),
                    borderRadius: BorderRadius.circular((height ?? 1.w) / 2),
                    boxShadow: [
                      BoxShadow(
                        color: (gradientColors?.first ?? AppColors.missionGreen)
                            .withValues(alpha:0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
