import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';

import '../../core/utils/colors.dart';
import '../../domain/entities/launch_entity.dart';
import '../providers/launch_provider.dart';
import '../widgets/common/modern_card.dart';
import '../widgets/common/spacex_header.dart';
import '../widgets/common/network_error_widget.dart';

/// Launch Tracker Screen - Task 2.3
/// 
/// Displays SpaceX launches with countdown timers and real-time updates.
/// Features modern glassmorphism UI, tabbed navigation, and immersive launch tracking.
class LaunchesScreen extends StatefulWidget {
  const LaunchesScreen({super.key});

  @override
  State<LaunchesScreen> createState() => _LaunchesScreenState();
}

class _LaunchesScreenState extends State<LaunchesScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _countdownController;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();

    // Initialize tab controller with 3 tabs
    _tabController = TabController(length: 3, vsync: this);

    // Initialize countdown animation controller
    _countdownController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    // Start real-time countdown timer
    _startCountdownTimer();

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);

    // Fetch launches when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LaunchProvider>().fetchLaunches();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _countdownController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// Starts real-time countdown timer
  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Update countdown displays every second
        });
      }
    });
  }

  /// Handles scroll for pagination
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<LaunchProvider>().loadMoreLaunches();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: AppColors.getScreenAccentOverlay(
          isDark: isDark,
          screenType: AppScreenType.launches,
          child: Container(
            decoration: AppColors.getScreenBackground(
              isDark: isDark,
              screenType: AppScreenType.launches,
            ),
            child: CustomScrollView(
              slivers: [
                // Premium SpaceX Header
                SliverToBoxAdapter(
                  child: Consumer<LaunchProvider>(
                    builder: (context, provider, child) {
                      final upcomingLaunches = provider.upcomingLaunches.length;
                      final pastLaunches = provider.pastLaunches.length;
                      final successfulLaunches = provider.pastLaunches.where((l) => l.success == true).length;

                      return SpaceXHeader(
                        title: 'Launch Tracker',
                        subtitle: 'Real-time SpaceX Launch Monitoring',
                        icon: Icons.rocket_launch_rounded,
                        primaryColor: AppColors.launchRed,
                        secondaryColor: AppColors.rocketOrange,
                        showFilter: false,
                      );
                    },
                  ),
                ),

                // Stats Section
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.all(4.w),
                    child: Consumer<LaunchProvider>(
                      builder: (context, provider, child) {
                        final upcomingLaunches = provider.upcomingLaunches.length;
                        final pastLaunches = provider.pastLaunches.length;
                        final successfulLaunches = provider.pastLaunches.where((l) => l.success == true).length;
                        
                        return Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Upcoming\nLaunches',
                                upcomingLaunches.toString(),
                                Icons.schedule,
                                AppColors.rocketOrange,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: _buildStatCard(
                                'Past\nLaunches',
                                pastLaunches.toString(),
                                Icons.history,
                                AppColors.spaceBlue,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: _buildStatCard(
                                'Success\nRate',
                                pastLaunches > 0
                                  ? '${((successfulLaunches / pastLaunches) * 100).toInt()}%'
                                  : '0%',
                                Icons.trending_up,
                                AppColors.missionGreen,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // Tab Bar
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.all(4.w),
                    child: ModernCard(
                      isDark: true,
                      borderRadius: 20,
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: AppColors.rocketGradient,
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white70,
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.rocket_launch, size: 4.w),
                                SizedBox(width: 2.w),
                                Text('Launches', style: TextStyle(fontSize: 3.w)),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.launch, size: 4.w),
                                SizedBox(width: 2.w),
                                Text('Pads', style: TextStyle(fontSize: 3.w)),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.flight_land, size: 4.w),
                                SizedBox(width: 2.w),
                                Text('Landing', style: TextStyle(fontSize: 3.w)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Tab content
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLaunchesTab(),
                      _buildLaunchpadsTab(),
                      _buildLandpadsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds individual stat cards
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 5.w),
            SizedBox(height: 1.w),
            Text(
              value,
              style: TextStyle(
                fontSize: 4.w,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 2.5.w,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the launches tab content
  Widget _buildLaunchesTab() {
    return Consumer<LaunchProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.launches.isEmpty) {
          return Container(
            height: 50.h,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        }

        if (provider.error != null && provider.launches.isEmpty) {
          return NetworkErrorWidget(
            onRetry: () => provider.fetchLaunches(),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.refreshLaunches(),
          backgroundColor: AppColors.cardSurface,
          color: AppColors.rocketOrange,
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(4.w),
            itemCount: provider.launches.length + (provider.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= provider.launches.length) {
                return Container(
                  height: 10.h,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                );
              }

              final launch = provider.launches[index];
              return _buildLaunchCard(launch);
            },
          ),
        );
      },
    );
  }

  /// Builds launch card with countdown timer
  Widget _buildLaunchCard(LaunchEntity launch) {
    final isUpcoming = launch.dateUtc?.isAfter(DateTime.now()) ?? false;
    final timeUntilLaunch = isUpcoming && launch.dateUtc != null
        ? launch.dateUtc!.difference(DateTime.now())
        : null;

    return ModernCard(
      isDark: true,
      onTap: () => _navigateToLaunchDetail(launch),
      margin: EdgeInsets.only(bottom: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Launch status and countdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
                decoration: BoxDecoration(
                  color: isUpcoming ? AppColors.rocketOrange : AppColors.missionGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isUpcoming ? 'UPCOMING' : 'COMPLETED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 2.5.w,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isUpcoming && timeUntilLaunch != null)
                _buildCountdownTimer(timeUntilLaunch),
            ],
          ),
          SizedBox(height: 3.w),

          // Launch name and mission
          Text(
            launch.missionName ?? 'Unknown Mission',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2.w),

          // Launch details
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 12.sp,
                color: Colors.white70,
              ),
              SizedBox(width: 2.w),
              Text(
                launch.dateUtc != null
                    ? '${launch.dateUtc!.day}/${launch.dateUtc!.month}/${launch.dateUtc!.year}'
                    : 'Date TBD',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white70,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.rocket,
                size: 12.sp,
                color: Colors.white70,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  launch.rocket?.name ?? 'Unknown Rocket',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.w),

          // Success indicator
          Row(
            children: [
              Icon(
                launch.success == true
                    ? Icons.check_circle
                    : launch.success == false
                    ? Icons.cancel
                    : Icons.help_outline,
                color: launch.success == true
                    ? AppColors.missionGreen
                    : launch.success == false
                    ? AppColors.launchRed
                    : Colors.white70,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Text(
                launch.success == true
                    ? 'Success'
                    : launch.success == false
                    ? 'Failed'
                    : 'Pending',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: launch.success == true
                      ? AppColors.missionGreen
                      : launch.success == false
                      ? AppColors.launchRed
                      : Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 4.w,
                color: Colors.white70,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds countdown timer widget
  Widget _buildCountdownTimer(Duration timeLeft) {
    final days = timeLeft.inDays;
    final hours = timeLeft.inHours % 24;
    final minutes = timeLeft.inMinutes % 60;
    final seconds = timeLeft.inSeconds % 60;

    return AnimatedBuilder(
      animation: _countdownController,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
          decoration: BoxDecoration(
            gradient: AppColors.rocketGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer, color: Colors.white, size: 3.w),
              SizedBox(width: 1.w),
              Text(
                '${days}d ${hours}h ${minutes}m ${seconds}s',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 2.5.w,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds launchpads tab (placeholder)
  Widget _buildLaunchpadsTab() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: ModernCard(
        isDark: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.launch,
              size: 15.w,
              color: AppColors.rocketOrange,
            ),
            SizedBox(height: 4.w),
            Text(
              'Launchpads',
              style: TextStyle(
                fontSize: 6.w,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2.w),
            Text(
              'Coming Soon!',
              style: TextStyle(
                fontSize: 4.w,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds landpads tab (placeholder)
  Widget _buildLandpadsTab() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: ModernCard(
        isDark: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flight_land,
              size: 15.w,
              color: AppColors.missionGreen,
            ),
            SizedBox(height: 4.w),
            Text(
              'Landing Pads',
              style: TextStyle(
                fontSize: 6.w,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2.w),
            Text(
              'Coming Soon!',
              style: TextStyle(
                fontSize: 4.w,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigates to launch detail screen
  void _navigateToLaunchDetail(LaunchEntity launch) {
    Get.snackbar(
      'Launch Selected',
      launch.missionName ?? 'Unknown Mission',
      backgroundColor: AppColors.spaceBlue.withOpacity(0.8),
      colorText: Colors.white,
    );
  }
}