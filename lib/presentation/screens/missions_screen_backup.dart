import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';

import '../providers/mission_provider.dart';
import '../widgets/common/spacex_card.dart';
import '../widgets/common/error_widgets.dart';
import '../widgets/common/modern_card.dart';
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
      builder: (context) => Container(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.deepSpaceGradient,
        ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Hero Section with Modern Design
            SliverAppBar(
              expandedHeight: 30.h,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeroSection(isDark),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: Icon(
                    _isGridView ? Icons.view_list : Icons.grid_view,
                    color: Colors.white,
                  ),
                  onPressed: () => setState(() => _isGridView = !_isGridView),
                ),
                IconButton(
                  icon: Icon(
                    _showSearch ? Icons.close : Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: () => setState(() => _showSearch = !_showSearch),
                ),
              ],
            ),
            
            // Search Bar (when visible)
            if (_showSearch)
              SliverToBoxAdapter(
                child: ModernSearchBar(
                  hintText: 'Search missions...',
                  isDark: isDark,
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onFilterTap: _showFilterSheet,
                ),
              ),
            
            // Mission Content
            Consumer<MissionProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.missions.isEmpty) {
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
                
                if (provider.error != null && provider.missions.isEmpty) {
                  return SliverToBoxAdapter(
                    child: NetworkErrorWidget(
                      onRetry: () => provider.fetchMissions(),
                    ),
                  );
                }
                
                return _buildMissionContent(provider, isDark);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the hero section with modern glassmorphism design
  Widget _buildHeroSection(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.spaceGradient,
      ),
      child: Stack(
        children: [
          // Animated background particles
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.spaceBlue.withValues(alpha:0.1),
                    AppColors.cosmicPurple.withValues(alpha:0.05),
                  ],
                ),
              ),
            ),
          ),
          // Hero content
          Positioned(
            bottom: 8.w,
            left: 4.w,
            right: 4.w,
            child: ModernCard(
              isDark: true,
              borderRadius: 20,
              elevation: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ModernIconContainer(
                        icon: Icons.explore_rounded,
                        gradientColors: [
                          AppColors.rocketOrange,
                          AppColors.launchRed,
                        ],
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Missions',
                              style: TextStyle(
                                fontSize: 6.w,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Explore SpaceX Mission Objectives',
                              style: TextStyle(
                                fontSize: 3.5.w,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.w),
                  Consumer<MissionProvider>(
                    builder: (context, provider, child) {
                      return Row(
                        children: [
                          _buildStatCard(
                            'Total Missions',
                            provider.missions.length.toString(),
                            Icons.rocket_launch,
                            AppColors.spaceBlue,
                          ),
                          SizedBox(width: 3.w),
                          _buildStatCard(
                            'Manufacturers',
                            provider.missions.isNotEmpty 
                              ? provider.missions.first.manufacturerCount.toString()
                              : '0',
                            Icons.factory,
                            AppColors.missionGreen,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds individual stat cards
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha:0.3),
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

  /// Builds the mission content based on view type
  Widget _buildMissionContent(MissionProvider provider, bool isDark) {
    if (_isGridView) {
      return SliverPadding(
        padding: EdgeInsets.all(4.w),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 4.w,
            mainAxisSpacing: 4.w,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= provider.missions.length) {
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
              return _buildMissionGridCard(provider.missions[index], isDark);
            },
            childCount: provider.missions.length + (provider.isLoading ? 1 : 0),
          ),
        ),
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= provider.missions.length) {
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
            return _buildMissionListCard(provider.missions[index], isDark);
          },
          childCount: provider.missions.length + (provider.isLoading ? 1 : 0),
        ),
      );
    }
  }

  /// Builds mission grid card with modern design
  Widget _buildMissionGridCard(MissionEntity mission, bool isDark) {
    return ModernCard(
      isDark: isDark,
      onTap: () => _navigateToMissionDetail(mission),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mission status indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
            decoration: BoxDecoration(
              color: mission.hasLinks
                  ? AppColors.missionGreen
                  : AppColors.rocketOrange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              mission.hasLinks ? 'ACTIVE' : 'PLANNED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 2.5.w,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 3.w),
          Text(
            mission.name,
            style: TextStyle(
              fontSize: 4.w,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.w),
          Text(
            mission.description ?? 'No description available',
            style: TextStyle(
              fontSize: 3.w,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                Icons.factory,
                size: 3.w,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 1.w),
              Text(
                '${mission.manufacturerCount} manufacturers',
                style: TextStyle(
                  fontSize: 2.5.w,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds mission list card with modern design
  Widget _buildMissionListCard(MissionEntity mission, bool isDark) {
    return ModernCard(
      isDark: isDark,
      onTap: () => _navigateToMissionDetail(mission),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      child: Row(
        children: [
          ModernIconContainer(
            icon: mission.hasLinks
                ? Icons.check_circle
                : Icons.schedule,
            gradientColors: mission.hasLinks
                ? [AppColors.missionGreen, AppColors.missionGreen]
                : [AppColors.rocketOrange, AppColors.rocketOrange],
            size: 2.w,
            iconSize: 5.w,
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.name,
                  style: TextStyle(
                    fontSize: 4.w,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 1.w),
                Text(
                  mission.description ?? 'No description available',
                  style: TextStyle(
                    fontSize: 3.w,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.w),
                Row(
                  children: [
                    Icon(
                      Icons.factory,
                      size: 3.w,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      mission.manufacturersString,
                      style: TextStyle(
                        fontSize: 2.5.w,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 4.w,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  /// Navigates to mission detail screen
  void _navigateToMissionDetail(MissionEntity mission) {
    // TODO: Implement mission detail navigation
    Get.snackbar(
      'Mission Selected',
      mission.name,
      backgroundColor: AppColors.spaceBlue.withValues(alpha:0.8),
      colorText: Colors.white,
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
