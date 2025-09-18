import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../core/utils/colors.dart';
import '../../core/utils/spacing.dart';
import '../../core/utils/typography.dart';
import '../../domain/entities/launch_entity.dart';
import '../../domain/entities/launchpad_entity.dart';
import '../../domain/entities/landpad_entity.dart';
import '../providers/launch_provider.dart';
import '../providers/launchpad_provider.dart';
import '../providers/landpad_provider.dart';
import '../widgets/common/glass_background.dart';
import '../widgets/common/modern_card.dart';
import '../widgets/loading/launch_shimmer.dart';

// Launch Tracker Screen with Dynamic GraphQL Data
class LaunchesScreen extends StatefulWidget {
  const LaunchesScreen({super.key});

  @override
  State<LaunchesScreen> createState() => _LaunchesScreenState();
}

class _LaunchesScreenState extends State<LaunchesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _startCountdownTimer();

    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LaunchProvider>().fetchLaunches();
      context.read<LaunchpadProvider>().fetchLaunchpads();
      context.read<LandpadProvider>().fetchLandpads();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Update countdown logic here
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Launches',
                      style: AppTypography.getHeadline(isDark),
                    ),
                    const SizedBox.shrink(),
                  ],
                ),
              ),

              // Tab Bar
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                child: TabBar(
                  controller: _tabController,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(
                      color: AppColors.spaceBlue,
                      width: 3.0,
                    ),
                    insets: EdgeInsets.symmetric(horizontal: 0),
                  ),
                  labelColor: isDark ? Colors.white : Colors.black,
                  unselectedLabelColor: isDark ? AppColors.textSecondary : AppColors.darkTextSecondary,
                  labelStyle: AppTypography.getBody(isDark).copyWith(
                    fontWeight: AppTypography.medium,
                  ),
                  unselectedLabelStyle: AppTypography.getBody(isDark),
                  indicatorPadding: EdgeInsets.zero,
                  tabs: const [
                    Tab(text: 'Launches'),
                    Tab(text: 'Launchpad'),
                    Tab(text: 'Landpad'),
                  ],
                ),
              ),

              AppSpacing.gapVerticalM,

              // Tab Views
              Expanded(
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
    );
  }


  /// Builds the launches tab content with provider data
  Widget _buildLaunchesTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<LaunchProvider>(
      builder: (context, launchProvider, child) {
        if (launchProvider.isLoading) {
          return const LaunchesScreenShimmer();
        }

        if (launchProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading launches',
                  style: AppTypography.getBody(isDark),
                ),
                AppSpacing.gapVerticalS,
                ElevatedButton(
                  onPressed: () => launchProvider.fetchLaunches(),
                  child: Text(
                    'Retry',
                    style: AppTypography.getBody(isDark).copyWith(
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            // Trigger load more when user scrolls near the bottom
            if (!launchProvider.isLoadingMore &&
                launchProvider.hasMoreData &&
                scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 200) {
              launchProvider.loadMoreLaunches();
            }
            return false;
          },
          child: SingleChildScrollView(
            padding: AppSpacing.paddingHorizontalM,
            child: Column(
              children: [
                // Statistics Cards
                _buildStatisticsCards(launchProvider, isDark),
                AppSpacing.gapVerticalL,

                // Launch cards with staggered animations
                ...launchProvider.launches.asMap().entries.map((entry) {
                  final index = entry.key;
                  final launch = entry.value;
                  return ModernCard(
                    isDark: isDark,
                    margin: const EdgeInsets.only(bottom: AppSpacing.m),
                    animationDelay: Duration(milliseconds: index * 100),
                    onTap: () {
                      // TODO: Navigate to launch details
                    },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Mission name (title)
                          Text(
                            launch.missionName,
                            style: AppTypography.getTitle(isDark),
                          ),
                          if (launch.details != null) ...[
                            AppSpacing.gapVerticalXS,
                            Text(
                              launch.details!,
                              style: AppTypography.getBody(isDark),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          AppSpacing.gapVerticalS,
                          
                          // Status and date row
                          Row(
                            children: [
                              Container(
                                padding: AppSpacing.paddingXS,
                                decoration: BoxDecoration(
                                  color: launch.success == true 
                                      ? AppColors.missionGreen.withValues(alpha: 0.2)
                                      : launch.success == false
                                          ? Colors.red.withValues(alpha: 0.2)
                                          : Colors.orange.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(AppSpacing.s),
                                  border: Border.all(
                                    color: launch.success == true 
                                        ? AppColors.missionGreen
                                        : launch.success == false
                                            ? Colors.red
                                            : Colors.orange,
                                  ),
                                ),
                                child: Text(
                                  launch.success == true 
                                      ? 'Success'
                                      : launch.success == false
                                          ? 'Failed'
                                          : 'Upcoming',
                                  style: AppTypography.getCaption(isDark).copyWith(
                                    color: launch.success == true 
                                        ? AppColors.missionGreen
                                        : launch.success == false
                                            ? Colors.red
                                            : Colors.orange,
                                    fontWeight: AppTypography.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (launch.dateUtc != null)
                                Text(
                                  _formatDate(launch.dateUtc!),
                                  style: AppTypography.getCaption(isDark),
                                ),
                            ],
                          ),
                          
                          // Flight number and launch site
                          if (launch.flightNumber > 0) ...[
                            AppSpacing.gapVerticalXS,
                            Text(
                              'Flight #${launch.flightNumber}',
                              style: AppTypography.getBody(isDark).copyWith(
                                fontWeight: AppTypography.medium,
                              ),
                            ),
                          ],
                          if (launch.launchSite != null) ...[
                            AppSpacing.gapVerticalXS,
                            Text(
                              'Launch Site: ${launch.launchSite!.displayName}',
                              style: AppTypography.getBody(isDark),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),

                // Load more button or loading indicator
                if (launchProvider.isLoadingMore)
                  Padding(
                    padding: AppSpacing.paddingM,
                    child: Column(
                      children: List.generate(3, (index) => const LaunchShimmer()),
                    ),
                  )
                else if (launchProvider.hasMoreData)
                  Padding(
                    padding: AppSpacing.paddingM,
                    child: ElevatedButton(
                      onPressed: () => launchProvider.loadMoreLaunches(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.cardSurface : AppColors.lightCard,
                        foregroundColor: isDark ? AppColors.textPrimary : AppColors.darkText,
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.s + AppSpacing.xs),
                          side: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                      ),
                      child: Text(
                        'Load More Launches',
                        style: AppTypography.getBody(isDark).copyWith(
                          fontWeight: AppTypography.medium,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds statistics cards for launches tab
  Widget _buildStatisticsCards(LaunchProvider launchProvider, bool isDark) {
    final upcomingCount = launchProvider.upcomingLaunches.length;
    final pastCount = launchProvider.pastLaunches.length;
    final successfulLaunches = launchProvider.pastLaunches.where((launch) => launch.success == true).length;
    final successRate = pastCount > 0 ? (successfulLaunches / pastCount * 100) : 0.0;

    return Row(
      children: [
        // Upcoming Card
        _buildStatCard(
          title: 'UPCOMING',
          value: upcomingCount.toString(),
          isDark: isDark,
        ),
        
        // Past Card
        _buildStatCard(
          title: 'PAST',
          value: pastCount.toString(),
          isDark: isDark,
        ),
        
        // Success Rate Card
        _buildStatCard(
          title: 'SUCCESS %',
          value: successRate.toStringAsFixed(1),
          isDark: isDark,
          isSuccessRate: true,
        ),
      ],
    );
  }

  /// Builds individual statistic card
  Widget _buildStatCard({
    required String title,
    required String value,
    required bool isDark,
    bool isSuccessRate = false,
  }) {
    return Expanded(
      child: ModernCard(
        isDark: isDark,
        margin: EdgeInsets.symmetric(horizontal: 1.w),
        padding: EdgeInsets.all(3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.getCaption(isDark).copyWith(
                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                fontWeight: AppTypography.medium,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              value,
              style: AppTypography.getHeadline(isDark).copyWith(
                color: isSuccessRate 
                  ? const Color(0xFF10B981) // Green for success rate
                  : (isDark ? Colors.white : Colors.black87),
                fontWeight: AppTypography.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }


  /// Builds launchpads tab content
  Widget _buildLaunchpadsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<LaunchpadProvider>(
      builder: (context, launchpadProvider, child) {
        if (launchpadProvider.isLoading) {
          return const Center(child: LaunchShimmer());
        }

        if (launchpadProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading launchpads',
                  style: AppTypography.getBody(isDark),
                ),
                AppSpacing.gapVerticalS,
                ElevatedButton(
                  onPressed: () => launchpadProvider.fetchLaunchpads(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (!launchpadProvider.isLoadingMore &&
                launchpadProvider.hasMoreData &&
                scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 200) {
              launchpadProvider.loadMoreLaunchpads();
            }
            return false;
          },
          child: SingleChildScrollView(
            padding: AppSpacing.paddingHorizontalM,
            child: Column(
              children: [
                // Launchpad cards
                ...launchpadProvider.launchpads.map((launchpad) =>
                    ModernCard(
                      isDark: isDark,
                      margin: const EdgeInsets.only(bottom: AppSpacing.m),
                      onTap: () {
                        // TODO: Navigate to launchpad details
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            launchpad.name,
                            style: AppTypography.getTitle(isDark),
                          ),
                          if (launchpad.details != null) ...[
                            AppSpacing.gapVerticalXS,
                            Text(
                              launchpad.details!,
                              style: AppTypography.getBody(isDark),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          AppSpacing.gapVerticalS,
                          Row(
                            children: [
                              Container(
                                padding: AppSpacing.paddingXS,
                                decoration: BoxDecoration(
                                  color: launchpad.status == 'active'
                                      ? AppColors.missionGreen
                                      : AppColors.rocketOrange,
                                  borderRadius: BorderRadius.circular(AppSpacing.s),
                                ),
                                child: Text(
                                  launchpad.status == 'active' ? 'Active' : 'Inactive',
                                  style: AppTypography.getCaption(isDark).copyWith(
                                    color: Colors.white,
                                    fontWeight: AppTypography.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (launchpad.successfulLaunches != null)
                                Text(
                                  '${launchpad.successfulLaunches} launches',
                                  style: AppTypography.getCaption(isDark),
                                ),
                            ],
                          ),
                          if (launchpad.location != null) ...[
                            AppSpacing.gapVerticalS,
                            Text(
                              '${launchpad.location!.name}, ${launchpad.location!.region}',
                              style: AppTypography.getCaption(isDark),
                            ),
                          ],
                        ],
                      ),
                    )),

                // Load more button or loading indicator
                if (launchpadProvider.isLoadingMore)
                  const Padding(
                    padding: AppSpacing.paddingM,
                    child: LaunchShimmer(),
                  )
                else if (launchpadProvider.hasMoreData)
                  Padding(
                    padding: AppSpacing.paddingM,
                    child: ElevatedButton(
                      onPressed: () => launchpadProvider.loadMoreLaunchpads(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.cardSurface : AppColors.lightCard,
                        foregroundColor: isDark ? AppColors.textPrimary : AppColors.darkText,
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.s + AppSpacing.xs),
                          side: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                      ),
                      child: Text(
                        'Load More Launchpads',
                        style: AppTypography.getBody(isDark).copyWith(
                          fontWeight: AppTypography.medium,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds landpads tab content
  Widget _buildLandpadsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<LandpadProvider>(
      builder: (context, landpadProvider, child) {
        if (landpadProvider.isLoading) {
          return const Center(child: LaunchShimmer());
        }

        if (landpadProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading landpads',
                  style: AppTypography.getBody(isDark),
                ),
                AppSpacing.gapVerticalS,
                ElevatedButton(
                  onPressed: () => landpadProvider.fetchLandpads(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (!landpadProvider.isLoadingMore &&
                landpadProvider.hasMoreData &&
                scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 200) {
              landpadProvider.loadMoreLandpads();
            }
            return false;
          },
          child: SingleChildScrollView(
            padding: AppSpacing.paddingHorizontalM,
            child: Column(
              children: [
                // Landpad cards
                ...landpadProvider.landpads.map((landpad) =>
                    ModernCard(
                      isDark: isDark,
                      margin: EdgeInsets.only(bottom: 2.h),
                      onTap: () {
                        // TODO: Navigate to landpad details
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            landpad.fullName,
                            style: AppTypography.getTitle(isDark),
                          ),
                          if (landpad.details != null) ...[
                            SizedBox(height: 0.5.h),
                            Text(
                              landpad.details!,
                              style: AppTypography.getBody(isDark),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          SizedBox(height: 1.h),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 0.5.h),
                                decoration: BoxDecoration(
                                  color: landpad.status == 'active'
                                      ? AppColors.missionGreen
                                      : AppColors.rocketOrange,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  landpad.status == 'active' ? 'Active' : 'Inactive',
                                  style: AppTypography.getCaption(isDark).copyWith(
                                    color: Colors.white,
                                    fontWeight: AppTypography.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (landpad.successfulLandings != null)
                                Text(
                                  '${landpad.successfulLandings} landings',
                                  style: AppTypography.getCaption(isDark),
                                ),
                            ],
                          ),
                          if (landpad.landingType != null) ...[
                            SizedBox(height: 0.5.h),
                            Text(
                              'Type: ${landpad.landingType}',
                              style: AppTypography.getCaption(isDark),
                            ),
                          ],
                          if (landpad.location != null) ...[
                            SizedBox(height: 0.5.h),
                            Text(
                              '${landpad.location!.name}, ${landpad.location!.region}',
                              style: AppTypography.getCaption(isDark),
                            ),
                          ],
                        ],
                      ),
                    )),

                // Load more button or loading indicator
                if (landpadProvider.isLoadingMore)
                  const Padding(
                    padding: AppSpacing.paddingM,
                    child: LaunchShimmer(),
                  )
                else if (landpadProvider.hasMoreData)
                  Padding(
                    padding: AppSpacing.paddingM,
                    child: ElevatedButton(
                      onPressed: () => landpadProvider.loadMoreLandpads(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.cardSurface : AppColors.lightCard,
                        foregroundColor: isDark ? AppColors.textPrimary : AppColors.darkText,
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.s + AppSpacing.xs),
                          side: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                      ),
                      child: Text(
                        'Load More Landpads',
                        style: AppTypography.getBody(isDark).copyWith(
                          fontWeight: AppTypography.medium,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds launchpad card
  Widget _buildLaunchpadCard(LaunchpadEntity launchpad, bool isDark) {
    final statusColor = launchpad.status == 'active'
        ? AppColors.missionGreen
        : AppColors.rocketOrange;
    final status = launchpad.status == 'active' ? 'Active' : 'Inactive';

    return ModernCard(
      isDark: isDark,
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: AppSpacing.paddingM,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status and name row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(AppSpacing.xs + 2),
                ),
                child: Text(
                  status,
                  style: AppTypography.getCaption(isDark).copyWith(
                    color: Colors.white,
                    fontWeight: AppTypography.medium,
                  ),
                ),
              ),
              if (launchpad.successfulLaunches != null)
                Text(
                  '${launchpad.successfulLaunches} launches',
                  style: AppTypography.getCaption(isDark),
                ),
            ],
          ),
          AppSpacing.gapVerticalS,

          // Name and location
          Text(
            launchpad.name,
            style: AppTypography.getTitle(isDark),
          ),
          if (launchpad.location != null)
            Text(
              '${launchpad.location!.name}, ${launchpad.location!.region}',
              style: AppTypography.getCaption(isDark),
            ),
          AppSpacing.gapVerticalS,

          // Details
          if (launchpad.details != null && launchpad.details!.isNotEmpty)
            Text(
              launchpad.details!,
              style: AppTypography.getBody(isDark),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  /// Builds landpad card
  Widget _buildLandpadCard(LandpadEntity landpad, bool isDark) {
    final statusColor = landpad.status == 'active'
        ? AppColors.missionGreen
        : AppColors.rocketOrange;
    final status = landpad.status == 'active' ? 'Active' : 'Inactive';

    return ModernCard(
      isDark: isDark,
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: AppSpacing.paddingM,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status and stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(AppSpacing.xs + 2),
                ),
                child: Text(
                  status,
                  style: AppTypography.getCaption(isDark).copyWith(
                    color: Colors.white,
                    fontWeight: AppTypography.medium,
                  ),
                ),
              ),
              if (landpad.successfulLandings != null)
                Text(
                  '${landpad.successfulLandings} landings',
                  style: AppTypography.getCaption(isDark),
                ),
            ],
          ),
          AppSpacing.gapVerticalS,

          // Name and type
          Text(
            landpad.fullName,
            style: AppTypography.getTitle(isDark),
          ),
          if (landpad.landingType != null)
            Text(
              'Type: ${landpad.landingType}',
              style: AppTypography.getCaption(isDark),
            ),
          if (landpad.location != null)
            Text(
              '${landpad.location!.name}, ${landpad.location!.region}',
              style: AppTypography.getCaption(isDark),
            ),
          AppSpacing.gapVerticalS,

          // Details
          if (landpad.details != null && landpad.details!.isNotEmpty)
            Text(
              landpad.details!,
              style: AppTypography.getBody(isDark),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  /// Formats date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d from now';
    } else if (difference.inDays < 0) {
      return '${-difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h from now';
    } else if (difference.inHours < 0) {
      return '${-difference.inHours}h ago';
    } else {
      return 'Today';
    }
  }
}
