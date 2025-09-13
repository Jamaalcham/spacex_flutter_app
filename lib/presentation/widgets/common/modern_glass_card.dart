import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/utils/colors.dart';
import '../../../core/utils/spacing.dart';
import '../../../core/utils/typography.dart';

/// Modern glass morphism card with enhanced readability
class ModernGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool hasGlow;
  final Color? glowColor;
  final double borderRadius;
  final double blurIntensity;

  const ModernGlassCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.hasGlow = false,
    this.glowColor,
    this.borderRadius = 16.0,
    this.blurIntensity = 10.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Widget card = Container(
      width: width,
      height: height,
      margin: margin ?? AppSpacing.paddingS,
      padding: padding ?? AppSpacing.paddingM,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ]
            : [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.7),
              ],
        ),
        border: Border.all(
          color: isDark 
            ? Colors.white.withOpacity(0.2)
            : Colors.white.withOpacity(0.8),
          width: 1.5,
        ),
        boxShadow: [
          if (hasGlow && glowColor != null)
            BoxShadow(
              color: glowColor!.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          BoxShadow(
            color: isDark 
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.1),
            blurRadius: blurIntensity,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: isDark 
              ? Colors.white.withOpacity(0.05)
              : Colors.white.withOpacity(0.8),
            blurRadius: blurIntensity / 2,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

/// Enhanced stat card with modern design
class ModernStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback? onTap;

  const ModernStatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ModernGlassCard(
      onTap: onTap,
      hasGlow: true,
      glowColor: gradient.colors.first,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate responsive sizes based on available space
          final iconSize = constraints.maxWidth * 0.25;
          final fontSize = constraints.maxWidth * 0.15;
          
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container with responsive design
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  gradient: gradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: iconSize * 0.5,
                ),
              ),
              
              SizedBox(height: 2.h),
              
              // Value with responsive typography
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 1.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: isDark 
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    value,
                    style: AppTypography.getHeadline(isDark).copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: fontSize.clamp(16.0, 24.0),
                      foreground: Paint()
                        ..shader = gradient.createShader(
                          const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                        ),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              
              SizedBox(height: 1.h),
              
              // Title with responsive design
              Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1.w),
                  child: Text(
                    title,
                    style: AppTypography.getCaption(isDark).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 10.sp,
                      color: isDark 
                        ? Colors.white.withOpacity(0.9)
                        : Colors.black.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Enhanced navigation card with modern design
class ModernNavigationCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const ModernNavigationCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  }) : super(key: key);

  @override
  State<ModernNavigationCard> createState() => _ModernNavigationCardState();
}

class _ModernNavigationCardState extends State<ModernNavigationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: ModernGlassCard(
              hasGlow: _isPressed,
              glowColor: widget.gradient.colors.first,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final iconSize = constraints.maxWidth * 0.15;
                  final arrowSize = constraints.maxWidth * 0.08;
                  
                  return Row(
                    children: [
                      // Icon container with responsive sizing
                      Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          gradient: widget.gradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: widget.gradient.colors.first.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.icon,
                          color: Colors.white,
                          size: iconSize * 0.6,
                        ),
                      ),
                      
                      SizedBox(width: 3.w),
                      
                      // Content with flexible layout
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.title,
                              style: AppTypography.getTitle(isDark).copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 16.sp,
                                color: isDark 
                                  ? Colors.white
                                  : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            SizedBox(height: 0.5.h),
                            
                            Text(
                              widget.subtitle,
                              style: AppTypography.getBody(isDark).copyWith(
                                fontSize: 12.sp,
                                color: isDark 
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.black.withOpacity(0.6),
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(width: 2.w),
                      
                      // Arrow with responsive sizing
                      Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.gradient.colors.first.withOpacity(0.2),
                              widget.gradient.colors.last.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: widget.gradient.colors.first,
                          size: arrowSize,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
