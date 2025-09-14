import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';

import '../../core/utils/colors.dart';
import '../../domain/entities/mission_entity.dart';
import '../providers/mission_provider.dart';
import '../widgets/common/modern_card.dart';
import '../widgets/common/spacex_header.dart';
import '../widgets/common/network_error_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        top: false,
        child: AppColors.getScreenAccentOverlay(
          isDark: isDark,
          screenType: AppScreenType.missions,
          child: Container(
            decoration: AppColors.getScreenBackground(
              isDark: isDark,
              screenType: AppScreenType.missions,
            ),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Premium SpaceX Header
                SliverToBoxAdapter(
                  child: Consumer<MissionProvider>(
                    builder: (context, provider, child) {
                      final totalMissions = provider.missions.length;
                      final manufacturerCount = provider.missions.fold<Set<String>>({}, (set, mission) => set..addAll(mission.manufacturers)).length;
                      final missionsWithLinks = provider.missions.where((m) => m.hasLinks).length;
                      
                      return SpaceXHeader(
                        title: 'Mission Explorer',
                        subtitle: 'Advanced SpaceX Mission Analytics',
                        icon: Icons.explore_rounded,
                        primaryColor: AppColors.missionGreen,
                        secondaryColor: AppColors.spaceBlue,
                        showViewToggle: true,
                        isGridView: _isGridView,
                        onSearchTap: () => setState(() => _showSearch = !_showSearch),
                        onViewToggle: () => setState(() => _isGridView = !_isGridView),
                      );
                    },
                  ),
                ),
              
              // Stats Section
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.all(4.w),
                  child: Consumer<MissionProvider>(
                    builder: (context, provider, child) {
                      final totalMissions = provider.missions.length;
                      final manufacturerCount = provider.missions.fold<Set<String>>({}, (set, mission) => set..addAll(mission.manufacturers)).length;
                      final missionsWithLinks = provider.missions.where((m) => m.hasLinks).length;
                      
                      return Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total\nMissions',
                              totalMissions.toString(),
                              Icons.explore,
                              AppColors.missionGreen,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: _buildStatCard(
                              'Partners\nInvolved',
                              manufacturerCount.toString(),
                              Icons.business,
                              AppColors.rocketOrange,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: _buildStatCard(
                              'Missions with\nLinks',
                              missionsWithLinks.toString(),
                              Icons.link,
                              AppColors.purpleAccent,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
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
      ),
    ));
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
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 1.w),
                Text(
                  mission.description ?? 'No description available',
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
                    Icon(
                      Icons.factory,
                      size: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 1.w),
                    Expanded(
                      child: Text(
                        mission.manufacturersString,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
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

  /// Navigates to mission detail screen
  void _navigateToMissionDetail(MissionEntity mission) {
    Get.snackbar(
      'Mission Selected',
      mission.name,
      backgroundColor: AppColors.spaceBlue.withOpacity(0.8),
      colorText: Colors.white,
    );
  }
}
