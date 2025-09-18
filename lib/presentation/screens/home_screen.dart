import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/utils/colors.dart';
import '../../core/utils/spacing.dart';
import '../../core/utils/typography.dart';
import '../providers/theme_provider.dart';
import '../widgets/common/glass_background.dart';
import '../widgets/common/countdown_timer_widget.dart';

// Provides navigation to all major sections: Missions, Rockets, and Launches
// with quick stats and featured content previews.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _rocketAnimationController;
  late Animation<double> _rocketScaleAnimation;
  late Animation<double> _rocketRotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _rocketAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

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

    // Start rocket animation with delay and repeat
    Future.delayed(const Duration(milliseconds: 800), () {
      _rocketAnimationController.repeat(reverse: true);
    });

  }

  @override
  void dispose() {
    // _countdownTimer.cancel(); // No timer to cancel since we're not counting down
    _rocketAnimationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _rocketAnimationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _rocketScaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rocketRotationAnimation.value,
                    child: Icon(
                      Icons.rocket_launch_rounded,
                      color: isDark ? AppColors.rocketOrange : AppColors.spaceBlue,
                      size: 6.w,
                    ),
                  ),
                );
              },
            ),
            SizedBox(width: 2.w),
            Text(
              'SpaceX Explorer',
              style: AppTypography.getTitle(isDark).copyWith(
                fontWeight: AppTypography.bold,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Glass background
          const GlassBackground(
            secondaryColor: AppColors.rocketOrange,
            child: SizedBox.expand(),
          ),
          
          // Main content with rocket background
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + kToolbarHeight),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Add additional top spacing
                  SizedBox(height: 2.h),
                
                // Top section with rocket background and content
                Container(
                  width: 90.w,
                  height: 30.h,
                  margin: AppSpacing.paddingHorizontalM,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/rocket.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: isDark ? null : Border.all(
                      color: Colors.black.withOpacity(0.1),
                      width: 0.5,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black.withOpacity(0.7) : Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 2.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Main title
                          Text(
                            'Live Mission Countdown',
                            style: AppTypography.getHeadline(isDark).copyWith(
                              fontWeight: AppTypography.bold,
                              letterSpacing: 0.5,
                              color: AppColors.textPrimary,
                              shadows: [
                                Shadow(
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          SizedBox(height: 1.h),
                          
                          // Subtitle
                          Text(
                            'Next Launch: Falcon 9 - Starlink Mission',
                            style: AppTypography.getBody(isDark).copyWith(
                              fontWeight: AppTypography.medium,
                              color: AppColors.textPrimary,
                              shadows: [
                                Shadow(
                                  offset: const Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          SizedBox(height: 2.h),
                          
                          // Countdown timer
                          CountdownTimerWidget(
                            initialDuration: const Duration(
                              days: 4,
                              hours: 14,
                              minutes: 34,
                              seconds: 49,
                            ),
                            isDark: isDark,
                            onTimerComplete: () {
                              // Handle timer completion if needed
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                  // Mission Overview Section
                  SizedBox(height: 4.h),
                  _buildMissionOverviewSection(isDark),
                
                  // Launch Success Rate Section
                  SizedBox(height: 4.h),
                  _buildLaunchSuccessRateSection(isDark),
                  
                  // Bottom padding
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build Mission Overview section with stats cards
  Widget _buildMissionOverviewSection(bool isDark) {
    return Padding(
      padding: AppSpacing.paddingHorizontalM,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            'MISSION OVERVIEW',
            style: AppTypography.getCaption(isDark).copyWith(
              fontWeight: AppTypography.medium,
              letterSpacing: 0.5,
            ),
          ),
          
          SizedBox(height: 3.h),
          
          // Top row: Total Launches and Successful
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: (90.w - 3.w) / 2, // Exact half width minus spacing
                height: 15.h,
                child: _buildStatCard(
                  title: 'Total Launches',
                  value: '185',
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 3.w),
              SizedBox(
                width: (90.w - 3.w) / 2, // Exact half width minus spacing
                height: 15.h,
                child: _buildStatCard(
                  title: 'Successful',
                  value: '170',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 3.h),
          
          // Bottom row: Capsules Recovered (full width)
          _buildStatCard(
            title: 'Capsules Recovered',
            value: '150',
            isDark: isDark,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  /// Build Launch Success Rate section with progress bar
  Widget _buildLaunchSuccessRateSection(bool isDark) {
    return Padding(
      padding: AppSpacing.paddingHorizontalM,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            'LAUNCH SUCCESS RATE',
            style: AppTypography.getCaption(isDark).copyWith(
              fontWeight: AppTypography.medium,
              letterSpacing: 0.5,
            ),
          ),
          
          SizedBox(height: 3.h),
          
          // Success rate card with progress bar
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.glassBackground : AppColors.glassBackgroundLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overall Success Rate',
                      style: AppTypography.getBody(isDark).copyWith(
                        fontWeight: AppTypography.medium,
                      ),
                    ),
                    Text(
                      '81%',
                      style: AppTypography.getHeadline(isDark).copyWith(
                        fontWeight: AppTypography.bold,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 2.h),
                
                // Progress bar
                Container(
                  height: 1.h,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(0.5.h),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.81, // 92%
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.missionGreen,
                        borderRadius: BorderRadius.circular(0.5.h),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual stat card
  Widget _buildStatCard({
    required String title,
    required String value,
    required bool isDark,
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      height: 15.h, // Fixed height for consistent card sizes
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.glassBackground : AppColors.glassBackgroundLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTypography.getBody(isDark).copyWith(
              fontWeight: AppTypography.medium,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTypography.getHeadline(isDark).copyWith(
                fontWeight: AppTypography.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

}
