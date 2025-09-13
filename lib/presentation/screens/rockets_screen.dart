import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/rocket_provider.dart';
import '../widgets/common/spacex_card.dart';
import '../widgets/common/animated_components.dart';
import '../widgets/common/error_widgets.dart';
import '../widgets/common/space_themed_components.dart';
import '../../core/utils/colors.dart';
import '../../core/utils/app_theme.dart';
import '../../core/utils/localization/language_constants.dart';
import '../../domain/entities/rocket_entity.dart';

/// Rocket Gallery Screen - Task 2.2
/// 
/// Displays SpaceX rockets with detailed specifications in both list and grid view.
/// Features search, filtering by status, and comprehensive rocket information display.
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
    
    // Fetch rockets when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RocketProvider>().fetchRockets();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Handles search input changes
  void _onSearchChanged(String query) {
    context.read<RocketProvider>().searchRockets(query);
  }

  /// Handles pull-to-refresh
  Future<void> _onRefresh() async {
    await context.read<RocketProvider>().refreshRockets();
  }

  /// Shows rocket statistics bottom sheet
  void _showStatsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildStatsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SpaceHeader(
            title: getTranslated(context, 'rockets_title') ?? 'Rockets',
            subtitle: 'Discover rocket specifications',
            icon: Icons.rocket,
            showBackButton: true,
            trailing: IconButton(
              icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
              onPressed: () {
                setState(() {
                  _isGridView = !_isGridView;
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<RocketProvider>(
        builder: (context, provider, child) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          
          if (provider.isLoading && provider.rockets.isEmpty) {
            return ShimmerList(
              itemCount: 4,
              itemHeight: 25.h,
              isDark: isDark,
            );
          }

          if (provider.error != null && provider.rockets.isEmpty) {
            return NetworkErrorWidget(
              onRetry: () => provider.fetchRockets(),
            );
          }

          if (provider.isEmpty) {
            return SpaceEmptyState(
              title: 'No Rockets Found',
              subtitle: 'No SpaceX rockets match your current search criteria. Try adjusting your filters or search terms.',
              icon: Icons.rocket_launch_outlined,
              actionText: 'Refresh',
              onAction: () => provider.fetchRockets(),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
            color: AppColors.cosmicBlue,
            child: Column(
              children: [
                // Search bar (if visible)
                if (_showSearch) _buildSearchBar(),
                
                // Filter tabs and stats
                _buildFilterTabs(provider),
                
                // Rocket count and stats summary
                _buildHeader(provider),
                
                // Rockets gallery
                Expanded(
                  child: provider.isGridView
                      ? _buildGridView(provider)
                      : _buildListView(provider),
                ),
              ],
            ),
          );
        },
      ),
          ),
        ],
      ),
    );
  }

  /// Builds the app bar with search and view actions
  PreferredSizeWidget _buildAppBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppBar(
      title: Text(
        getTranslated(context, 'rockets') ?? 'Rockets',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 18.sp,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppColors.rocketGradient,
        ),
      ),
      actions: [
        // Search toggle button
        IconButton(
          icon: Icon(_showSearch ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) {
                _searchController.clear();
                context.read<RocketProvider>().searchRockets('');
              }
            });
          },
        ),
        
        // Statistics button
        IconButton(
          icon: const Icon(Icons.analytics),
          onPressed: _showStatsSheet,
        ),
        
        // View mode toggle
        Consumer<RocketProvider>(
          builder: (context, provider, child) {
            return IconButton(
              icon: Icon(provider.isGridView ? Icons.list : Icons.grid_view),
              onPressed: () => provider.toggleViewMode(),
            );
          },
        ),
      ],
    );
  }

  /// Builds the search bar
  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(4.w),
      color: AppColors.primary.withOpacity(0.1),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: getTranslated(context, 'search_hint') ?? 
                   'Search rockets by name or type...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  /// Builds filter tabs for rocket status
  Widget _buildFilterTabs(RocketProvider provider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    'All',
                    RocketFilter.all,
                    provider.currentFilter,
                    provider,
                    '${provider.rocketCount}',
                  ),
                  SizedBox(width: 2.w),
                  _buildFilterChip(
                    'Active',
                    RocketFilter.active,
                    provider.currentFilter,
                    provider,
                    '${provider.activeRocketCount}',
                  ),
                  SizedBox(width: 2.w),
                  _buildFilterChip(
                    'Retired',
                    RocketFilter.retired,
                    provider.currentFilter,
                    provider,
                    '${provider.retiredRocketCount}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds individual filter chip
  Widget _buildFilterChip(
    String label,
    RocketFilter filter,
    RocketFilter currentFilter,
    RocketProvider provider,
    String count,
  ) {
    final isSelected = currentFilter == filter;
    
    return GestureDetector(
      onTap: () => provider.filterRockets(filter),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            SizedBox(width: 1.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.2.h),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : AppColors.textSecondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds header with rocket information
  Widget _buildHeader(RocketProvider provider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${provider.rocketCount} ${getTranslated(context, 'rockets') ?? 'rockets'}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          Text(
            getTranslated(context, 'pull_to_refresh') ?? 'Pull to refresh',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds list view for rockets
  Widget _buildListView(RocketProvider provider) {
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 2.h),
      itemCount: provider.rockets.length,
      itemBuilder: (context, index) {
        final rocket = provider.rockets[index];
        return RocketCard(
          rocketName: rocket.name,
          description: rocket.description,
          isActive: rocket.active,
          successRate: rocket.successRatePct,
          cost: rocket.costPerLaunch,
          onTap: () => _navigateToRocketDetails(rocket),
        );
      },
    );
  }

  /// Builds grid view for rockets
  Widget _buildGridView(RocketProvider provider) {
    return GridView.builder(
      padding: EdgeInsets.all(2.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 2.w,
      ),
      itemCount: provider.rockets.length,
      itemBuilder: (context, index) {
        final rocket = provider.rockets[index];
        return _buildGridRocketCard(rocket);
      },
    );
  }

  /// Builds individual rocket card for grid view
  Widget _buildGridRocketCard(RocketEntity rocket) {
    return SpaceXCard(
      title: rocket.name,
      subtitle: rocket.description,
      padding: EdgeInsets.all(3.w),
      onTap: () => _navigateToRocketDetails(rocket),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rocket image or icon
          Container(
            width: double.infinity,
            height: 15.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.surface,
            ),
            child: _buildRocketIcon(rocket),
          ),
          
          SizedBox(height: 2.h),
          
          // Rocket name and status
          Row(
            children: [
              Expanded(
                child: Text(
                  rocket.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: rocket.active ? AppColors.success : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  rocket.active ? 'Active' : 'Retired',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 1.h),
          
          // Specifications
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSpecRow('Success Rate', rocket.formattedSuccessRate),
              _buildSpecRow('Cost/Launch', rocket.formattedCost),
              _buildSpecRow('Height', rocket.formattedHeight),
              _buildSpecRow('Mass', rocket.formattedMass),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds rocket icon for cards without images
  Widget _buildRocketIcon(RocketEntity rocket) {
    return Container(
      decoration: BoxDecoration(
        gradient: rocket.active ? AppColors.spaceGradient : null,
        color: rocket.active ? null : Colors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(
          Icons.rocket,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  /// Builds specification row for grid cards
  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds statistics bottom sheet
  Widget _buildStatsSheet() {
    return Consumer<RocketProvider>(
      builder: (context, provider, child) {
        final stats = provider.getRocketStats();
        
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              
              SizedBox(height: 2.h),
              
              // Title
              Text(
                'Rocket Statistics',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              SizedBox(height: 3.h),
              
              // Statistics grid
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 4.w,
                mainAxisSpacing: 2.h,
                children: [
                  _buildStatCard(
                    'Total Rockets',
                    '${provider.rocketCount}',
                    Icons.rocket,
                    AppColors.primary,
                  ),
                  _buildStatCard(
                    'Active',
                    '${provider.activeRocketCount}',
                    Icons.check_circle,
                    AppColors.success,
                  ),
                  _buildStatCard(
                    'Retired',
                    '${provider.retiredRocketCount}',
                    Icons.history,
                    Colors.grey,
                  ),
                  if (stats['averageSuccessRate'] != null)
                    _buildStatCard(
                      'Avg Success',
                      '${stats['averageSuccessRate'].toStringAsFixed(1)}%',
                      Icons.trending_up,
                      AppColors.success,
                    ),
                ],
              ),
              
              SizedBox(height: 4.h),
              
              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Close'),
                ),
              ),
              
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  /// Builds individual statistic card
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 6.w),
          SizedBox(height: 1.h),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Navigates to rocket details screen
  void _navigateToRocketDetails(RocketEntity rocket) {
    // TODO: Implement navigation to rocket details screen
    Get.snackbar(
      'Rocket Selected',
      '${rocket.name} - ${rocket.active ? "Active" : "Retired"}',
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
    );
  }
}
