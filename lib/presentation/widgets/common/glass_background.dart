import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/utils/colors.dart';

/// Universal Glass Prism Background Widget
/// 
/// Extracted from SpaceXHeader to provide a consistent glassmorphism background
/// across all screens in the app. Features animated particles and glass effects.
class GlassBackground extends StatefulWidget {
  final Widget child;
  final bool showParticles;
  final Color? secondaryColor;

  const GlassBackground({
    super.key,
    required this.child,
    this.showParticles = true,
    this.secondaryColor,
  });

  @override
  State<GlassBackground> createState() => _GlassBackgroundState();
}

class _GlassBackgroundState extends State<GlassBackground>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    
    // Float animation for particles
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Stack(
      children: [
        // Base background
        _buildAnimatedBackground(isDark),
        
        // Floating particles (only in dark mode)
        if (widget.showParticles && isDark) _buildFloatingParticles(),
        
        // Glassmorphism overlay
        _buildGlassmorphismOverlay(isDark),
        
        // Content
        widget.child,
      ],
    );
  }

  Widget _buildAnimatedBackground(bool isDark) {
    final baseColor = isDark 
        ? AppColors.darkSpace 
        : Colors.white;
    const primaryColor = AppColors.spaceBlue;
    
    return Container(
      width: 100.w,
      height: 100.h,
      decoration: BoxDecoration(
        color: isDark 
            ? baseColor.withOpacity(0.9)
            : baseColor.withOpacity(0.2),
        backgroundBlendMode: BlendMode.overlay,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark ? [
              primaryColor.withOpacity(0.1),
              primaryColor.withOpacity(0.05),
              AppColors.darkSpace.withOpacity(0.8),
            ] : [
              Colors.white.withOpacity(0.6),
              Colors.white.withOpacity(0.3),
            ],
            stops: isDark ? [0.0, 0.5, 1.0] : [0.0, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(25, (index) {
            final offset = _floatAnimation.value * (index % 2 == 0 ? 1 : -1);
            
            // Create more evenly distributed positions
            final row = index ~/ 5; // 5 particles per row
            final col = index % 5;  // Column position
            
            // Base positions with better distribution
            final baseLeft = (10 + col * 18).w; // Spread across width
            final baseTop = (8 + row * 16).h;   // Spread across height
            
            // Add some randomness for natural look
            final randomOffsetX = (index * 13) % 7 - 3; // -3 to 3
            final randomOffsetY = (index * 17) % 5 - 2; // -2 to 2
            
            return Positioned(
              left: baseLeft + (offset * 2.w) + randomOffsetX.w,
              top: baseTop + (offset * 1.h) + randomOffsetY.h,
              child: Container(
                width: (0.6 + (index % 4) * 0.15).w, // Varied sizes
                height: (0.6 + (index % 4) * 0.15).w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.rocketOrange.withOpacity(0.7 - (index % 8) * 0.05),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.rocketOrange.withOpacity(0.3),
                      blurRadius: 1.5.w,
                      spreadRadius: 0.3.w,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildGlassmorphismOverlay(bool isDark) {
    return Container(
      width: 100.w,
      height: 100.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(isDark ? 0.05 : 0.3),
            Colors.transparent,
            Colors.black.withOpacity(isDark ? 0.1 : 0.05),
          ],
        ),
      ),
    );
  }
}
