import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';

import '../../core/utils/colors.dart';
import '../../domain/entities/rocket_entity.dart';
import '../providers/rocket_provider.dart';
import '../widgets/common/modern_card.dart';
import '../widgets/common/network_error_widget.dart';
import '../widgets/common/glass_background.dart';
import '../widgets/common/custom_app_bar.dart';

/// Rocket Gallery Screen - Task 2.2
/// 
/// Displays SpaceX rockets with immersive 3D-like presentations using
/// gradient backgrounds and neumorphic/glassmorphism effects.
class RocketsScreen extends StatefulWidget {
  const RocketsScreen({super.key});

  @override
  State<RocketsScreen> createState() => _RocketsScreenState();
}

class _RocketsScreenState extends State<RocketsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Fetch rockets when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RocketProvider>().fetchRockets();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Handles scroll events for pagination
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      // Note: RocketProvider doesn't support pagination yet
      // This could be implemented in the future for large datasets
    }
  }

  /// Handles search input changes
  void _onSearchChanged(String query) {
    context.read<RocketProvider>().searchRockets(query);
  }

  /// Shows rocket stats bottom sheet
  void _showStatsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rocket Statistics',
              style: TextStyle(
                fontSize: 5.w,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.w),
            Text('Detailed rocket statistics coming soon!'),
            SizedBox(height: 4.w),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar matching settings screen
              CustomAppBar.rockets(
                onSearch: () => setState(() => _showSearch = !_showSearch),
                onFilter: _showFilterSheet,
                onViewToggle: () => setState(() => _isGridView = !_isGridView),
                isGridView: _isGridView,
              ),
              
              // Content
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
              
              // Subtitle Section
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Text(
                    'Immersive SpaceX Rocket Showcase',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha:0.8)
                          : const Color(0xFF4A5568),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              
              // Stats Section
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.all(4.w),
                  child: Consumer<RocketProvider>(
                    builder: (context, provider, child) {
                      final activeRockets = provider.rockets.where((r) => r.active == true).length;
                      final totalRockets = provider.rockets.length;
                      
                      return Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Active\nRockets',
                              activeRockets.toString(),
                              Icons.rocket_launch,
                              AppColors.missionGreen,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: _buildStatCard(
                              'Total\nFleet',
                              totalRockets.toString(),
                              Icons.inventory,
                              AppColors.rocketOrange,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: _buildStatCard(
                              'Success\nRate',
                              totalRockets > 0 
                                ? '${((activeRockets / totalRockets) * 100).toInt()}%'
                                : '0%',
                              Icons.trending_up,
                              AppColors.spaceBlue,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              
              // Search bar if enabled
              if (_showSearch)
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.all(4.w),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search rockets...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        // Implement search functionality
                      },
                    ),
                  ),
                ),
              
              // Rocket content
              Consumer<RocketProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.rockets.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Container(
                        height: 50.h,
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                    );
                  }
                  
                  if (provider.error != null && provider.rockets.isEmpty) {
                    return SliverToBoxAdapter(
                      child: NetworkErrorWidget(
                        onRetry: () => provider.fetchRockets(),
                      ),
                    );
                  }
                  
                  return _buildRocketContent(provider, isDark);
                },
              ),
            ],
          ),
        ),
      ]
          ),
    )));
  }


  /// Shows filter bottom sheet
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter Options',
              style: TextStyle(
                fontSize: 5.w,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.w),
            Text('Filter functionality coming soon!'),
            SizedBox(height: 4.w),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds individual stat cards
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(1.5.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: color.withValues(alpha:0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 3.w),
          SizedBox(height: 0.5.w),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 7.sp,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the rocket content based on view type
  Widget _buildRocketContent(RocketProvider provider, bool isDark) {
    if (_isGridView) {
      return SliverPadding(
        padding: EdgeInsets.all(4.w),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 4.w,
            mainAxisSpacing: 4.w,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= provider.rockets.length) {
                return provider.isLoading
                    ? Container(
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              }
              return _buildRocketGridCard(provider.rockets[index], isDark);
            },
            childCount: provider.rockets.length + (provider.isLoading ? 1 : 0),
          ),
        ),
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= provider.rockets.length) {
              return provider.isLoading
                  ? Container(
                      height: 10.h,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            }
            return _buildRocketListCard(provider.rockets[index], isDark);
          },
          childCount: provider.rockets.length + (provider.isLoading ? 1 : 0),
        ),
      );
    }
  }

  /// Builds rocket grid card with 3D visual effects
  Widget _buildRocketGridCard(RocketEntity rocket, bool isDark) {
    return ModernCard(
      isDark: isDark,
      onTap: () => _navigateToRocketDetail(rocket),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rocket status indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.w),
            decoration: BoxDecoration(
              color: rocket.active == true
                  ? AppColors.missionGreen
                  : AppColors.textSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              rocket.active == true ? 'ACTIVE' : 'RETIRED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 2.w),
          Text(
            rocket.name ?? 'Unknown Rocket',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 1.w),
          Flexible(
            child: Text(
              rocket.description ?? 'No description available',
              style: TextStyle(
                fontSize: 10.sp,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 1.w),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.height,
                      size: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 1.w),
                    Flexible(
                      child: Text(
                        '${rocket.height?.meters?.toInt() ?? 0}m',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 1.w),
                    Flexible(
                      child: Text(
                        '${rocket.mass?.kg?.toInt() ?? 0}kg',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds rocket list card with modern design
  Widget _buildRocketListCard(RocketEntity rocket, bool isDark) {
    return ModernCard(
      isDark: isDark,
      onTap: () => _navigateToRocketDetail(rocket),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      child: Row(
        children: [
          ModernIconContainer(
            icon: rocket.active == true
                ? Icons.rocket_launch
                : Icons.rocket,
            gradientColors: rocket.active == true
                ? [AppColors.missionGreen, AppColors.missionGreen]
                : [AppColors.textSecondary, AppColors.textSecondary],
            size: 12.sp,
            iconSize: 5.w,
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rocket.name ?? 'Unknown Rocket',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 1.w),
                Text(
                  rocket.description ?? 'No description available',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.w),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Height: ${rocket.height?.meters?.toInt() ?? 0}m',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        'Mass: ${rocket.mass?.kg?.toInt() ?? 0}kg',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16.sp,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  /// Navigates to rocket detail screen
  void _navigateToRocketDetail(RocketEntity rocket) {
    Get.snackbar(
      'Rocket Selected',
      rocket.name ?? 'Unknown Rocket',
      backgroundColor: AppColors.rocketOrange.withValues(alpha:0.8),
      colorText: Colors.white,
    );
  }
}
