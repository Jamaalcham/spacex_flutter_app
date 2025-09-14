import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/utils/spacing.dart';
import '../../core/utils/typography.dart';
import '../../core/utils/localization/language_constants.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/common/modern_glass_card.dart';

/// Home Screen - Main navigation hub for the SpaceX Explorer app
/// 
/// Provides navigation to all major sections: Missions, Rockets, and Launches
/// with quick stats and featured content previews.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _rocketAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rocketScaleAnimation;
  late Animation<double> _rocketRotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _rocketAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Rocket jumping/zooming animation
    _rocketScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _rocketAnimationController,
      curve: Curves.elasticOut,
    ));

    // Subtle rotation animation
    _rocketRotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _rocketAnimationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    
    // Start rocket animation with delay and repeat
    Future.delayed(const Duration(milliseconds: 800), () {
      _rocketAnimationController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rocketAnimationController.dispose();
    super.dispose();
  }

  void _navigateToSection(int index) {
    // Navigate to main navigation screen with specific tab
    Navigator.of(context).pushReplacementNamed('/main', arguments: index);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF0F172A), // Deep space
                      const Color(0xFF1E293B), // Nebula
                      const Color(0xFF334155), // Cosmic dust
                    ]
                  : [
                      const Color(0xFFF8FAFC),
                      const Color(0xFFE2E8F0),
                    const Color(0xFFCBD5E1),
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: AppSpacing.paddingHorizontalM,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSpacing.gapVerticalL,
                      
                      // Enhanced Header Section
                      _buildModernHeader(context, isDark, themeProvider, languageProvider),
                  
                      AppSpacing.gapVerticalXL,
                  
                      // Enhanced Stats Section
                      _buildModernSectionHeader(
                        context,
                        getTranslated(context, 'missions') ?? 'Mission Stats',
                        getTranslated(context, 'app_subtitle') ?? 'Explore SpaceX Data',
                        Icons.analytics_outlined,
                        isDark,
                      ),
                      
                      AppSpacing.gapVerticalL,
                  
                      // Modern Stats Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 1.1,
                        mainAxisSpacing: 3.w,
                        crossAxisSpacing: 3.w,
                        children: [
                          ModernStatCard(
                            title: 'Total Missions',
                            value: '150+',
                            icon: Icons.rocket_launch_rounded,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          ModernStatCard(
                            title: 'Active Rockets',
                            value: '12',
                            icon: Icons.rocket_rounded,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          ModernStatCard(
                            title: 'Success Rate',
                            value: '94%',
                            icon: Icons.verified_rounded,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          ModernStatCard(
                            title: 'Upcoming Launches',
                            value: '8',
                            icon: Icons.schedule_rounded,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ],
                      ),
                      
                      AppSpacing.gapVerticalXL,
                      
                      // Featured Content Section
                      _buildModernSectionHeader(
                        context,
                        getTranslated(context, 'gallery') ?? 'Featured Content',
                        getTranslated(context, 'details') ?? 'Latest SpaceX Highlights',
                        Icons.star_rounded,
                        isDark,
                      ),
                      
                      AppSpacing.gapVerticalL,
                      
                      // Featured Cards
                      Column(
                        children: [
                          ModernNavigationCard(
                            title: 'Latest Launch',
                            subtitle: 'Starship IFT-6 Mission Success',
                            icon: Icons.rocket_launch_rounded,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: () => _navigateToSection(2),
                          ),
                          AppSpacing.gapVerticalM,
                          ModernNavigationCard(
                            title: 'Rocket Spotlight',
                            subtitle: 'Falcon Heavy - Triple Core Power',
                            icon: Icons.rocket_rounded,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: () => _navigateToSection(1),
                          ),
                          AppSpacing.gapVerticalM,
                          ModernNavigationCard(
                            title: 'Mission Update',
                            subtitle: 'Crew Dragon ISS Operations',
                            icon: Icons.flight_takeoff_rounded,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF10B981)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: () => _navigateToSection(0),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ));
  }

  /// Modern header with enhanced design
  Widget _buildModernHeader(BuildContext context, bool isDark, ThemeProvider themeProvider, LanguageProvider languageProvider) {
    return ModernGlassCard(
      padding: AppSpacing.paddingL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _rocketAnimationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _rocketScaleAnimation.value,
                    child: Transform.rotate(
                      angle: _rocketRotationAnimation.value,
                      child: Container(
                        padding: AppSpacing.paddingM,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E3A8A).withOpacity(0.4),
                              blurRadius: 20 * _rocketScaleAnimation.value,
                              spreadRadius: 2 * _rocketScaleAnimation.value,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.rocket_launch_rounded,
                          color: Colors.white,
                          size: 8.w,
                        ),
                      ),
                    ),
                  );
                },
              ),
              AppSpacing.gapHorizontalL,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getTranslated(context, 'app_title') ?? 'SpaceX Explorer',
                      style: AppTypography.getHeadline(isDark).copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 22.sp,
                      ),
                    ),
                    Text(
                      getTranslated(context, 'app_subtitle') ?? 'Discover the future of space exploration',
                      style: AppTypography.getBody(isDark).copyWith(
                        fontSize: 14.sp,
                        color: isDark 
                          ? Colors.white70 
                          : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              // Theme and language controls
              Row(
                children: [
                  Container(
                    padding: AppSpacing.paddingS,
                    decoration: BoxDecoration(
                      color: isDark 
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: GestureDetector(
                      onTap: () => themeProvider.toggleTheme(),
                      child: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: isDark ? Colors.white : Colors.black87,
                        size: 20.sp,
                      ),
                    ),
                  ),
                  AppSpacing.gapHorizontalS,
                  Container(
                    padding: AppSpacing.paddingS,
                    decoration: BoxDecoration(
                      color: isDark 
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: GestureDetector(
                      onTap: () async => await languageProvider.toggleLanguage(),
                      child: Text(
                        languageProvider.currentLanguage.languageCode == 'en' ? 'FR' : 'EN',
                        style: AppTypography.getCaption(isDark).copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Modern section header with enhanced design
  Widget _buildModernSectionHeader(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool isDark,
  ) {
    return Padding(
      padding: AppSpacing.paddingHorizontalS,
      child: Row(
        children: [
          Container(
            padding: AppSpacing.paddingS,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8B5CF6).withOpacity(0.2),
                  const Color(0xFF6366F1).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF8B5CF6),
              size: 20.sp,
            ),
          ),
          AppSpacing.gapHorizontalM,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.getTitle(isDark).copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.getCaption(isDark).copyWith(
                    color: isDark 
                      ? Colors.white.withOpacity(0.6)
                      : Colors.black.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

  }

}
