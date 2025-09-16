import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/utils/colors.dart';
import '../../core/utils/spacing.dart';
import '../../core/utils/typography.dart';
import '../../domain/entities/rocket_entity.dart';
import '../providers/rocket_provider.dart';
import '../widgets/common/glass_background.dart';
import '../widgets/common/network_error_widget.dart';
import 'rocket_detail_screen.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/loading/rocket_shimmer.dart';

// Rocket Gallery Screen - Task 2.2
class RocketsScreen extends StatefulWidget {
  const RocketsScreen({super.key});

  @override
  State<RocketsScreen> createState() => _RocketsScreenState();
}

class _RocketsScreenState extends State<RocketsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  bool _isGridView = false;

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

  // Handles scroll events for pagination
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      // Note: RocketProvider doesn't support pagination yet
      // This could be implemented in the future for large datasets
    }
  }

  // Handles search input changes
  void _onSearchChanged(String query) {
    context.read<RocketProvider>().searchRockets(query);
  }

  // Handles filter selection
  void _onFilterChanged(RocketFilter filter) {
    context.read<RocketProvider>().filterRockets(filter);
  }

  // Shows rocket stats bottom sheet
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
              ),
              
              // Content
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
              // Search bar if enabled
              if (_showSearch)
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.all(4.w),
                    child: TextField(
                      controller: _searchController,
                      style: AppTypography.getBody(isDark),
                      decoration: InputDecoration(
                        hintText: 'Search rockets by name or type...',
                        hintStyle: AppTypography.getCaption(isDark),
                        prefixIcon: Icon(
                          Icons.search,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: isDark 
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.white.withValues(alpha: 0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark 
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.black.withValues(alpha: 0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark 
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.black.withValues(alpha: 0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.spaceBlue,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        _onSearchChanged(value);
                        setState(() {}); // Rebuild to show/hide clear button
                      },
                    ),
                  ),
                ),
              
              // Search/Filter results indicator
              Consumer<RocketProvider>(
                builder: (context, provider, child) {
                  if (provider.searchQuery.isNotEmpty || provider.currentFilter != RocketFilter.all) {
                    return SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: isDark 
                              ? AppColors.spaceBlue.withValues(alpha: 0.1)
                              : AppColors.spaceBlue.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.spaceBlue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.spaceBlue,
                              size: 4.w,
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                _getResultsText(provider),
                                style: AppTypography.getCaption(isDark).copyWith(
                                  color: AppColors.spaceBlue,
                                ),
                              ),
                            ),
                            if (provider.searchQuery.isNotEmpty || provider.currentFilter != RocketFilter.all)
                              TextButton(
                                onPressed: () {
                                  provider.clearFilters();
                                  _searchController.clear();
                                  setState(() {});
                                },
                                child: Text(
                                  'Clear',
                                  style: TextStyle(
                                    color: AppColors.spaceBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              // Rocket content
              Consumer<RocketProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.rockets.isEmpty) {
                    return const RocketListSliverShimmer();
                  }
                  
                  if (provider.error != null && provider.rockets.isEmpty) {
                    return SliverToBoxAdapter(
                      child: NetworkErrorWidget(
                        onRetry: () => provider.fetchRockets(),
                      ),
                    );
                  }

                  if (provider.rockets.isEmpty && !provider.isLoading) {
                    return SliverToBoxAdapter(
                      child: _buildEmptyState(provider, isDark),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer<RocketProvider>(
        builder: (context, provider, child) => Container(
          padding: EdgeInsets.only(
            left: 4.w,
            right: 4.w,
            top: 4.w,
            bottom: MediaQuery.of(context).viewPadding.bottom + 4.w,
          ),
          decoration: BoxDecoration(
            color: isDark 
                ? const Color(0xFF1A1A1A).withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Container(
                  width: 12.w,
                  height: 1.w,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white54 : Colors.black54,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 4.w),
              Text(
                'Filter Rockets',
                style: AppTypography.getHeadline(isDark),
              ),
              SizedBox(height: 4.w),
              
              // Filter options
              _buildFilterOption(
                'All Rockets',
                'Show all available rockets',
                Icons.rocket_launch,
                RocketFilter.all,
                provider.currentFilter,
                isDark,
              ),
              _buildFilterOption(
                'Active Rockets',
                'Currently operational rockets',
                Icons.check_circle,
                RocketFilter.active,
                provider.currentFilter,
                isDark,
              ),
              _buildFilterOption(
                'Retired Rockets',
                'No longer in service',
                Icons.history,
                RocketFilter.retired,
                provider.currentFilter,
                isDark,
              ),
              
              SizedBox(height: 4.w),
              
              // Clear filters button
              if (provider.currentFilter != RocketFilter.all || provider.searchQuery.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      provider.clearFilters();
                      _searchController.clear();
                      Get.back();
                    },
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear All Filters'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 3.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              
              SizedBox(height: 2.w),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds individual filter option
  Widget _buildFilterOption(
    String title,
    String subtitle,
    IconData icon,
    RocketFilter filter,
    RocketFilter currentFilter,
    bool isDark,
  ) {
    final isSelected = filter == currentFilter;
    
    return Container(
      margin: EdgeInsets.only(bottom: 2.w),
      child: InkWell(
        onTap: () {
          _onFilterChanged(filter);
          Get.back();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.spaceBlue.withValues(alpha: 0.2) : AppColors.spaceBlue.withValues(alpha: 0.1))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.spaceBlue
                  : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.spaceBlue
                      : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black87),
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.getBody(isDark).copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.spaceBlue
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.getCaption(isDark),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.spaceBlue,
                  size: 5.w,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Gets results text for search/filter indicator
  String _getResultsText(RocketProvider provider) {
    final count = provider.rockets.length;
    
    if (provider.searchQuery.isNotEmpty && provider.currentFilter != RocketFilter.all) {
      final filterName = _getFilterName(provider.currentFilter);
      return 'Found $count $filterName rockets matching "${provider.searchQuery}"';
    } else if (provider.searchQuery.isNotEmpty) {
      return 'Found $count rockets matching "${provider.searchQuery}"';
    } else if (provider.currentFilter != RocketFilter.all) {
      final filterName = _getFilterName(provider.currentFilter);
      return 'Showing $count $filterName rockets';
    }
    
    return 'Showing $count rockets';
  }

  /// Gets filter name for display
  String _getFilterName(RocketFilter filter) {
    switch (filter) {
      case RocketFilter.active:
        return 'active';
      case RocketFilter.retired:
        return 'retired';
      case RocketFilter.all:
        return '';
    }
  }

  /// Builds empty state widget
  Widget _buildEmptyState(RocketProvider provider, bool isDark) {
    return Container(
      height: 40.h,
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            provider.searchQuery.isNotEmpty 
                ? Icons.search_off 
                : Icons.rocket_launch_outlined,
            size: 15.w,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          SizedBox(height: 4.w),
          Text(
            provider.searchQuery.isNotEmpty 
                ? 'No rockets found'
                : 'No rockets available',
            style: AppTypography.getTitle(isDark).copyWith(
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          SizedBox(height: 2.w),
          Text(
            provider.searchQuery.isNotEmpty 
                ? 'Try adjusting your search terms or filters'
                : 'Check your connection and try again',
            style: AppTypography.getCaption(isDark),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.w),
          if (provider.searchQuery.isNotEmpty || provider.currentFilter != RocketFilter.all)
            ElevatedButton.icon(
              onPressed: () {
                provider.clearFilters();
                _searchController.clear();
                setState(() {});
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.spaceBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: () => provider.fetchRockets(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.spaceBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
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
    // Always use list view to match the uploaded design
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= provider.rockets.length) {
            return provider.isLoading
                ? SizedBox(
                    height: 10.h,
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          }
          return _buildRocketCard(provider.rockets[index], isDark);
        },
        childCount: provider.rockets.length + (provider.isLoading ? 1 : 0),
      ),
    );
  }

  /// Builds rocket card matching the uploaded design exactly
  Widget _buildRocketCard(RocketEntity rocket, bool isDark) {
    String? rocketImageUrl = rocket.flickrImages.isNotEmpty == true
        ? rocket.flickrImages.first
        : null;
    
    String subtitle = _generateRocketSubtitle(rocket);
    
    return GestureDetector(
      onTap: () => _navigateToRocketDetail(rocket),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.w),
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large rocket image at the top
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 30.h,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.spaceBlue,
                      AppColors.stellarBlue,
                    ],
                  ),
                ),
                child: rocketImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: rocketImageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.spaceBlue,
                                AppColors.stellarBlue,
                              ],
                            ),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white.withValues(alpha: 0.7),
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => _buildRocketPlaceholder(),
                      )
                    : _buildRocketPlaceholder(),
              ),
            ),
            
            // Content section
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rocket name (main title)
                  Text(
                    rocket.name ?? 'Unknown Rocket',
                    style: AppTypography.getTitle(isDark),
                  ),
                  
                  SizedBox(height: 1.w),
                  
                  // Subtitle
                  Text(
                    subtitle,
                    style: AppTypography.getCaption(isDark).copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  SizedBox(height: 3.w),
                  
                  // Description
                  Text(
                    rocket.description ?? 'No description available',
                    style: AppTypography.getBody(isDark),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 4.w),
                  
                  // More Details button
                  GestureDetector(
                    onTap: () => _navigateToRocketDetail(rocket),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 3.w),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'More Details',
                            style: AppTypography.getCaption(isDark).copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF3B82F6),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: const Color(0xFF3B82F6),
                            size: 16.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Generates appropriate subtitle for rocket
  String _generateRocketSubtitle(RocketEntity rocket) {
    if (rocket.name?.toLowerCase().contains('falcon 9') == true) {
      return 'Reusable Two-Stage Rocket';
    } else if (rocket.name?.toLowerCase().contains('falcon heavy') == true) {
      return 'Heavy-Lift Launch Vehicle';
    } else if (rocket.name?.toLowerCase().contains('starship') == true) {
      return 'Interplanetary Spacecraft';
    } else if (rocket.name?.toLowerCase().contains('falcon 1') == true) {
      return 'Light-Lift Launch Vehicle';
    } else if (rocket.stages != null && rocket.stages! > 1) {
      return 'Multi-Stage Launch Vehicle';
    } else if (rocket.active == true) {
      return 'Active Launch Vehicle';
    } else {
      return 'Retired Launch Vehicle';
    }
  }

  /// Builds placeholder for rocket image
  Widget _buildRocketPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.spaceBlue,
            AppColors.stellarBlue,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rocket_launch,
              size: 15.w,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            SizedBox(height: 2.w),
            Text(
              'Rocket Image',
              style: AppTypography.getBody(false).copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigates to rocket detail screen
  void _navigateToRocketDetail(RocketEntity rocket) {
    Get.to(
      () => RocketDetailScreen(
        rocketId: rocket.id,
        rocket: rocket,
      ),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }
}
