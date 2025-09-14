import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/utils/colors.dart';

/// Premium SpaceX Header Widget
/// 
/// A visually stunning, reusable header component designed for the SpaceX app.
/// Features advanced glassmorphism, particle effects, and responsive design
/// that would make even Elon Musk say "Wow, that's a creative app!"
class SpaceXHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;
  final VoidCallback? onViewToggle;
  final bool showSearch;
  final bool showFilter;
  final bool showViewToggle;
  final bool isGridView;

  const SpaceXHeader({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.primaryColor = AppColors.spaceBlue,
    this.secondaryColor = AppColors.rocketOrange,
    this.onSearchTap,
    this.onFilterTap,
    this.onViewToggle,
    this.showSearch = true,
    this.showFilter = true,
    this.showViewToggle = false,
    this.isGridView = false,
  }) : super(key: key);

  @override
  State<SpaceXHeader> createState() => _SpaceXHeaderState();
}

class _SpaceXHeaderState extends State<SpaceXHeader>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    
    // Float animation for particles
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
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
    
    return Container(
      height: 20.h,
      width: 100.w,
      child: Stack(
        children: [
          // Animated background with gradient
          _buildAnimatedBackground(isDark),
          
          // Floating particles
          _buildFloatingParticles(),
          
          // Main content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top action bar
                  _buildTopActionBar(),
                  
                  SizedBox(height: 3.h),
                  
                  // Hero section
                  _buildHeroSection(),
                ],
              ),
            ),
          ),
          
          // Glassmorphism overlay
          _buildGlassmorphismOverlay(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(bool isDark) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.0,
                0.3 + (_floatAnimation.value * 0.2),
                0.7 + (_floatAnimation.value * 0.1),
                1.0,
              ],
              colors: [
                widget.primaryColor.withOpacity(0.9),
                widget.secondaryColor.withOpacity(0.7),
                Color(0xFF0F172A).withOpacity(0.8),
                Colors.black.withOpacity(0.95),
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(
                  -0.5 + (_floatAnimation.value * 0.3),
                  -0.8 + (_floatAnimation.value * 0.2),
                ),
                radius: 1.5,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final offset = _floatAnimation.value * (index % 2 == 0 ? 1 : -1);
            return Positioned(
              left: (10 + index * 12).w + (offset * 5.w),
              top: (5 + index * 4).h + (offset * 2.h),
              child: Container(
                width: (1 + index * 0.3).w,
                height: (1 + index * 0.3).w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.6 - index * 0.05),
                  boxShadow: [
                    BoxShadow(
                      color: widget.primaryColor.withOpacity(0.3),
                      blurRadius: 2.w,
                      spreadRadius: 0.5.w,
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

  Widget _buildTopActionBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title on the left (drawer position)
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 2.w,
                offset: Offset(0, 1.w),
              ),
            ],
          ),
        ),
        
        // Action buttons on the right
        Row(
          children: [
            if (widget.showSearch)
              _buildActionButton(
                Icons.search_rounded,
                widget.onSearchTap,
              ),
            if (widget.showFilter)
              SizedBox(width: 2.w),
            if (widget.showFilter)
              _buildActionButton(
                Icons.tune_rounded,
                widget.onFilterTap,
              ),
            if (widget.showViewToggle)
              SizedBox(width: 2.w),
            if (widget.showViewToggle)
              _buildActionButton(
                widget.isGridView ? Icons.list_rounded : Icons.grid_view_rounded,
                widget.onViewToggle,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(2.5.w),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 2.w,
              offset: Offset(0, 1.w),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 5.w,
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Center(
      child: Text(
        widget.subtitle,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13.sp,
          color: Colors.white.withOpacity(0.9),
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
    );
  }


  Widget _buildGlassmorphismOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.transparent,
            Colors.black.withOpacity(0.1),
          ],
        ),
      ),
    );
  }
}

/// Data model for header statistics
class HeaderStat {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const HeaderStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}
