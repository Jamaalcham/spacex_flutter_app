import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/launch_provider.dart';
import '../widgets/common/spacex_card.dart';
import '../widgets/common/animated_components.dart';
import '../widgets/common/error_widgets.dart';
import '../widgets/common/space_themed_components.dart';
import '../../core/utils/colors.dart';
import '../../core/utils/app_theme.dart';
import '../../core/utils/localization/language_constants.dart';
import '../../domain/entities/launch_entity.dart';

/// Tabbed Launches Screen with Launches, Launchpads, and Landpads
class LaunchesScreen extends StatefulWidget {
  const LaunchesScreen({super.key});

  @override
  State<LaunchesScreen> createState() => _LaunchesScreenState();
}

class _LaunchesScreenState extends State<LaunchesScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  late AnimationController _countdownController;

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
    _searchController.dispose();
    _countdownController.dispose();
    super.dispose();
  }

  /// Handles scroll for pagination
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<LaunchProvider>().loadMoreLaunches();
    }
  }

  /// Handles search input changes
  void _onSearchChanged(String query) {
    context.read<LaunchProvider>().searchLaunches(query);
  }

  /// Handles pull-to-refresh
  Future<void> _onRefresh() async {
    await context.read<LaunchProvider>().refreshLaunches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SpaceHeader(
            title: getTranslated(context, 'launches_title') ?? 'Launches',
            subtitle: 'Track SpaceX launches and facilities',
            icon: Icons.rocket_launch,
            showBackButton: true,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.spaceGradient 
                    : AppColors.lightSpaceGradient,
              ),
              child: Column(
                children: [
              // Header with tabs
              _buildHeaderWithTabs(),
              
              // Tab content
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
        ],
      ),
    );
  }

  Widget _buildHeaderWithTabs() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  gradient: AppColors.spaceGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.rocket_launch,
                  color: Colors.white,
                  size: 6.w,
                ),
              ),
              
              SizedBox(width: 4.w),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Launch Operations',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                    Text(
                      'Launches, Pads & Facilities',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Search toggle button
              IconButton(
                onPressed: () {
                  setState(() {
                    _showSearch = !_showSearch;
                  });
                },
                icon: Icon(
                  _showSearch ? Icons.close : Icons.search,
                  color: Colors.white,
                  size: 6.w,
                ),
              ),
            ],
          ),
          
          // Search bar (if shown)
          if (_showSearch) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search launches...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                ),
              ),
            ),
          ],
          
          SizedBox(height: 2.h),
          
          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: AppColors.spaceGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.6),
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10.sp,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 10.sp,
              ),
              tabs: [
                Tab(
                  icon: Icon(Icons.rocket_launch, size: 5.w),
                  text: 'Launches',
                ),
                Tab(
                  icon: Icon(Icons.launch, size: 5.w),
                  text: 'Launchpads',
                ),
                Tab(
                  icon: Icon(Icons.flight_land, size: 5.w),
                  text: 'Landpads',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLaunchesTab() {
    return Consumer<LaunchProvider>(
      builder: (context, provider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        if (provider.isLoading && provider.launches.isEmpty) {
          return ShimmerList(
            itemCount: 5,
            itemHeight: 20.h,
            isDark: isDark,
          );
        }

        if (provider.error != null && provider.launches.isEmpty) {
          return NetworkErrorWidget(
            onRetry: () => provider.fetchLaunches(),
          );
        }

        if (provider.launches.isEmpty) {
          return EmptyStateWidget(
            title: 'No Launches Found',
            message: 'No SpaceX launches match your current search criteria. Try adjusting your filters or search terms.',
            icon: Icons.rocket_launch,
            actionText: 'Refresh',
            onAction: () => provider.fetchLaunches(),
          );
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          color: AppColors.cosmicBlue,
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(4.w),
            itemCount: provider.launches.length + (provider.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == provider.launches.length) {
                return Padding(
                  padding: EdgeInsets.all(2.h),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        gradient: AppColors.spaceGradient,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(
                        width: 6.w,
                        height: 6.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),
                );
              }

              final launch = provider.launches[index];
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 300 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: LaunchCard(
                          launch: launch,
                          onTap: () => _showLaunchDetails(launch),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLaunchpadsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return EmptyStateWidget(
      title: 'Launchpads Coming Soon',
      message: 'Launch facility data and detailed information about SpaceX launchpads will be available soon. Stay tuned for updates!',
      icon: Icons.launch,
      illustration: TweenAnimationBuilder<double>(
        duration: const Duration(seconds: 2),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                gradient: AppColors.rocketGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.rocketOrange.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.launch,
                color: Colors.white,
                size: 15.w,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLandpadsTab() {
    return EmptyStateWidget(
      title: 'Landpads Coming Soon',
      message: 'Landing facility data and detailed information about SpaceX landing pads will be available soon. Stay tuned for updates!',
      icon: Icons.flight_land,
      illustration: TweenAnimationBuilder<double>(
        duration: const Duration(seconds: 2),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.rotate(
            angle: value * 0.1,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                gradient: AppColors.nebulaGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cosmicPurple.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.flight_land,
                color: Colors.white,
                size: 15.w,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 2.h),
          Text(
            'Loading launches...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 15.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'Error loading launches',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 2.h),
          ElevatedButton(
            onPressed: () => context.read<LaunchProvider>().fetchLaunches(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rocket_launch,
            color: Colors.white.withOpacity(0.5),
            size: 15.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'No launches found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Try adjusting your search criteria',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Padding(
      padding: EdgeInsets.all(2.h),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  void _showLaunchDetails(LaunchEntity launch) {
    // TODO: Implement launch details screen
    Get.snackbar(
      'Launch Details',
      'Details for ${launch.missionName}',
      backgroundColor: AppColors.primary.withOpacity(0.8),
      colorText: Colors.white,
    );
  }
}
