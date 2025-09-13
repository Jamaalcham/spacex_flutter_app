import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';

import '../providers/mission_provider.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/common/spacex_card.dart';
import '../widgets/common/animated_components.dart';
import '../widgets/common/error_widgets.dart';
import '../widgets/common/space_themed_components.dart';
import '../../core/utils/colors.dart';
import '../../core/utils/app_theme.dart';
import '../../core/utils/localization/language_constants.dart';
import '../../domain/entities/mission_entity.dart';

/// Mission Explorer Screen - Task 2.1
/// 
/// Displays SpaceX missions in both list and grid view formats with
/// search, filter, and pagination capabilities. Implements pull-to-refresh
/// and provides detailed mission information.
class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Fetch missions when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MissionProvider>().fetchMissions();
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
      context.read<MissionProvider>().loadMoreMissions();
    }
  }

  /// Handles search input changes
  void _onSearchChanged(String query) {
    context.read<MissionProvider>().searchMissions(query);
  }

  /// Handles pull-to-refresh
  Future<void> _onRefresh() async {
    await context.read<MissionProvider>().refreshMissions();
  }

  /// Shows filter bottom sheet
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SpaceHeader(
            title: getTranslated(context, 'missions_title') ?? 'Missions',
            subtitle: 'Explore SpaceX mission objectives',
            icon: Icons.explore,
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
            child: Consumer<MissionProvider>(
        builder: (context, provider, child) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          
          if (provider.isLoading && provider.missions.isEmpty) {
            return ShimmerList(
              itemCount: 6,
              itemHeight: 18.h,
              isDark: isDark,
            );
          }

          if (provider.error != null && provider.missions.isEmpty) {
            return NetworkErrorWidget(
              onRetry: () => provider.fetchMissions(),
            );
          }

          if (provider.isEmpty) {
            return SpaceEmptyState(
              title: 'No Missions Found',
              subtitle: 'No SpaceX missions match your current search criteria. Try adjusting your filters or search terms.',
              icon: Icons.explore_off,
              actionText: 'Refresh',
              onAction: () => provider.fetchMissions(),
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
                
                // Filter chips
                if (provider.selectedManufacturers.isNotEmpty || 
                    provider.searchQuery.isNotEmpty)
                  _buildActiveFilters(provider),
                
                // Mission count and view toggle
                _buildHeader(provider),
                
                // Missions list/grid
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

  /// Builds the app bar with search and filter actions
  PreferredSizeWidget _buildAppBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppBar(
      title: Text(
        getTranslated(context, 'missions') ?? 'Missions',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppColors.lightText,
          fontSize: 18.sp,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppColors.nebulaGradient,
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
                context.read<MissionProvider>().searchMissions('');
              }
            });
          },
        ),
        
        // Filter button
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterSheet,
        ),
        
        // View mode toggle
        Consumer<MissionProvider>(
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
                   'Search missions...',
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

  /// Builds active filters display
  Widget _buildActiveFilters(MissionProvider provider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 2.w,
              children: [
                // Search query chip
                if (provider.searchQuery.isNotEmpty)
                  Chip(
                    label: Text('Search: ${provider.searchQuery}'),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      _searchController.clear();
                      provider.searchMissions('');
                    },
                  ),
                
                // Manufacturer filter chips
                ...provider.selectedManufacturers.map((manufacturer) =>
                  Chip(
                    label: Text(manufacturer),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      final updatedManufacturers = List<String>.from(
                          provider.selectedManufacturers)
                        ..remove(manufacturer);
                      provider.filterByManufacturers(updatedManufacturers);
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Clear all filters button
          TextButton(
            onPressed: () {
              _searchController.clear();
              provider.clearFilters();
            },
            child: Text(
              getTranslated(context, 'clear_filters') ?? 'Clear All',
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds header with mission count and view toggle info
  Widget _buildHeader(MissionProvider provider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${provider.missionCount} ${getTranslated(context, 'missions') ?? 'missions'}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          if (provider.hasMoreData && !provider.isLoadingMore)
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

  /// Builds list view for missions
  Widget _buildListView(MissionProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(bottom: 2.h),
      itemCount: provider.missions.length + (provider.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= provider.missions.length) {
          return Padding(
            padding: EdgeInsets.all(4.w),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.cosmicBlue,
                strokeWidth: 2,
              ),
            ),
          );
        }

        final mission = provider.missions[index];
        return MissionCard(
          missionName: mission.name,
          description: mission.description,
          manufacturers: mission.manufacturers,
          onTap: () => _navigateToMissionDetails(mission),
        );
      },
    );
  }

  /// Builds grid view for missions
  Widget _buildGridView(MissionProvider provider) {
    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(2.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 2.w,
      ),
      itemCount: provider.missions.length + (provider.isLoadingMore ? 2 : 0),
      itemBuilder: (context, index) {
        if (index >= provider.missions.length) {
          return Card(
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.cosmicBlue,
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        }

        final mission = provider.missions[index];
        return _buildGridMissionCard(mission);
      },
    );
  }

  /// Builds individual mission card for grid view
  Widget _buildGridMissionCard(MissionEntity mission) {
    return SpaceXCard(
      title: mission.name,
      subtitle: mission.description,
      height: 25.h,
      padding: EdgeInsets.all(3.w),
      onTap: () => _navigateToMissionDetails(mission),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mission icon
          Container(
            width: 15.w,
            height: 15.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.spaceGradient,
            ),
            child: const Icon(
              Icons.rocket_launch,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          SizedBox(height: 2.h),
          
          // Mission name
          Text(
            mission.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          SizedBox(height: 1.h),
          
          // Description
          if (mission.hasDescription)
            Expanded(
              child: Text(
                mission.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          
          // Manufacturer count
          if (mission.manufacturers.isNotEmpty) ...[
            const Spacer(),
            Text(
              '${mission.manufacturerCount} manufacturers',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds filter bottom sheet
  Widget _buildFilterSheet() {
    return Consumer<MissionProvider>(
      builder: (context, provider, child) {
        final allManufacturers = provider.getAllManufacturers();
        
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
                getTranslated(context, 'filter') ?? 'Filter Missions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              SizedBox(height: 3.h),
              
              // Manufacturers section
              Text(
                getTranslated(context, 'manufacturers') ?? 'Manufacturers',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              SizedBox(height: 1.h),
              
              // Manufacturers chips
              Wrap(
                spacing: 2.w,
                children: allManufacturers.map((manufacturer) {
                  final isSelected = provider.selectedManufacturers
                      .contains(manufacturer);
                  
                  return FilterChip(
                    label: Text(manufacturer),
                    selected: isSelected,
                    onSelected: (selected) {
                      final updatedManufacturers = List<String>.from(
                          provider.selectedManufacturers);
                      
                      if (selected) {
                        updatedManufacturers.add(manufacturer);
                      } else {
                        updatedManufacturers.remove(manufacturer);
                      }
                      
                      provider.filterByManufacturers(updatedManufacturers);
                    },
                  );
                }).toList(),
              ),
              
              SizedBox(height: 4.h),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        provider.clearFilters();
                        Get.back();
                      },
                      child: Text(
                        getTranslated(context, 'clear_filters') ?? 'Clear All',
                      ),
                    ),
                  ),
                  
                  SizedBox(width: 4.w),
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        getTranslated(context, 'apply_filters') ?? 'Apply',
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  /// Navigates to mission details screen
  void _navigateToMissionDetails(MissionEntity mission) {
    // TODO: Implement navigation to mission details screen
    Get.snackbar(
      'Mission Selected',
      mission.name,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
    );
  }
}
