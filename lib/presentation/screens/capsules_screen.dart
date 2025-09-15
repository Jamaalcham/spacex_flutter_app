import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';

import '../../core/utils/colors.dart';
import '../../domain/entities/capsule_entity.dart';
import '../providers/capsule_provider.dart';
import '../widgets/common/modern_card.dart';
import '../widgets/common/network_error_widget.dart';
import '../widgets/common/glass_background.dart';
import '../widgets/common/custom_app_bar.dart';

/// Capsule Explorer Screen - Task 2.1
/// 
/// Displays SpaceX capsules in both list and grid view formats with
/// search, filter, and pagination capabilities. Implements pull-to-refresh
/// and provides detailed capsule information.
class CapsulesScreen extends StatefulWidget {
  const CapsulesScreen({super.key});

  @override
  State<CapsulesScreen> createState() => _CapsulesScreenState();
}

class _CapsulesScreenState extends State<CapsulesScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Fetch capsules when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CapsuleProvider>().fetchCapsules();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
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
              CustomAppBar.capsules(
                onSearch: () => setState(() => _showSearch = !_showSearch),
                onFilter: _showFilterSheet,
                onViewToggle: () => setState(() => _isGridView = !_isGridView),
                isGridView: _isGridView,
              ),
              
              // Content
              Expanded(
                child: Consumer<CapsuleProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading && provider.capsules.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      );
                    }
                    
                    if (provider.error != null && provider.capsules.isEmpty) {
                      return Center(
                        child: NetworkErrorWidget(
                          onRetry: () => provider.fetchCapsules(),
                        ),
                      );
                    }
                    
                    return CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        // Search bar if enabled
                        if (_showSearch)
                          SliverToBoxAdapter(
                            child: Container(
                              margin: EdgeInsets.all(4.w),
                              child: TextField(
                                controller: _searchController,
                                onChanged: _onSearchChanged,
                                decoration: InputDecoration(
                                  hintText: 'Search capsules...',
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        
                        // Capsule content
                        _buildCapsuleContent(provider, isDark),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  /// Handles scroll events for pagination
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<CapsuleProvider>().loadMoreCapsules();
    }
  }

  /// Handles search input changes
  void _onSearchChanged(String query) {
    context.read<CapsuleProvider>().searchCapsules(query);
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

  /// Builds the capsule content based on view type
  Widget _buildCapsuleContent(CapsuleProvider provider, bool isDark) {
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
              if (index >= provider.capsules.length) {
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
              return _buildCapsuleGridCard(provider.capsules[index], isDark);
            },
            childCount: provider.capsules.length + (provider.isLoading ? 1 : 0),
          ),
        ),
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= provider.capsules.length) {
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
            return _buildCapsuleListCard(provider.capsules[index], isDark);
          },
          childCount: provider.capsules.length + (provider.isLoading ? 1 : 0),
        ),
      );
    }
  }

  /// Builds capsule grid card with modern design
  Widget _buildCapsuleGridCard(CapsuleEntity capsule, bool isDark) {
    return ModernCard(
      isDark: isDark,
      onTap: () => _navigateToCapsuleDetail(capsule),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Capsule status indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
            decoration: BoxDecoration(
              color: capsule.status == 'active'
                  ? AppColors.missionGreen
                  : capsule.status == 'retired'
                  ? AppColors.launchRed
                  : AppColors.rocketOrange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              capsule.status?.toUpperCase() ?? 'UNKNOWN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 2.5.w,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 3.w),
          Text(
            capsule.serial ?? 'Unknown Serial',
            style: TextStyle(
              fontSize: 4.w,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 2.w),
          Text(
            capsule.type ?? 'Unknown Type',
            style: TextStyle(
              fontSize: 3.w,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                Icons.flight_takeoff,
                size: 12.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 1.w),
              Text(
                '${capsule.reuseCount ?? 0} flights',
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

  /// Builds capsule list card with modern design
  Widget _buildCapsuleListCard(CapsuleEntity capsule, bool isDark) {
    return ModernCard(
      isDark: isDark,
      onTap: () => _navigateToCapsuleDetail(capsule),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      child: Row(
        children: [
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              color: (capsule.status == 'active'
                  ? AppColors.missionGreen
                  : capsule.status == 'retired'
                  ? AppColors.launchRed
                  : AppColors.rocketOrange).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(
                color: (capsule.status == 'active'
                    ? AppColors.missionGreen
                    : capsule.status == 'retired'
                    ? AppColors.launchRed
                    : AppColors.rocketOrange).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.rocket_launch,
              size: 6.w,
              color: capsule.status == 'active'
                  ? AppColors.missionGreen
                  : capsule.status == 'retired'
                  ? AppColors.launchRed
                  : AppColors.rocketOrange,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  capsule.serial ?? 'Unknown Serial',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 1.w),
                Text(
                  capsule.type ?? 'Unknown Type',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                SizedBox(height: 2.w),
                Row(
                  children: [
                    Icon(
                      Icons.flight_takeoff,
                      size: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 1.w),
                    Expanded(
                      child: Text(
                        '${capsule.reuseCount ?? 0} flights • ${capsule.status?.toUpperCase() ?? 'UNKNOWN'}',
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

  /// Navigates to capsule detail screen
  void _navigateToCapsuleDetail(CapsuleEntity capsule) {
    Get.snackbar(
      'Capsule Selected',
      capsule.serial ?? 'Unknown',
      backgroundColor: AppColors.spaceBlue.withValues(alpha: 0.8),
      colorText: Colors.white,
    );
  }
}
