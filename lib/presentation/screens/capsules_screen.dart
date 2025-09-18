import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';

import '../../core/utils/colors.dart';
import '../../core/utils/spacing.dart';
import '../../core/utils/typography.dart';
import '../../domain/entities/capsule_entity.dart';
import 'capsule_detail_screen.dart';
import '../providers/capsule_provider.dart';
import '../widgets/common/modern_card.dart';
import '../widgets/common/network_error_widget.dart';
import '../widgets/common/glass_background.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/loading/capsule_shimmer.dart';

/// Capsules Screen with REST API Integration capabilities./// and provides detailed capsule information.
class CapsulesScreen extends StatefulWidget {
  const CapsulesScreen({super.key});

  @override
  State<CapsulesScreen> createState() => _CapsulesScreenState();
}

class _CapsulesScreenState extends State<CapsulesScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
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
    _debounceTimer?.cancel();
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
                      return _isGridView 
                          ? const CapsuleGridShimmer()
                          : const CapsuleListShimmer();
                    }
                    
                    if (provider.error != null && provider.capsules.isEmpty) {
                      return Center(
                        child: NetworkErrorWidget(
                          onRetry: () => provider.fetchCapsules(),
                        ),
                      );
                    }
                    
                    return RefreshIndicator(
                      onRefresh: () => provider.refreshCapsules(),
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
                                  autofocus: true,
                                  textInputAction: TextInputAction.search,
                                  onSubmitted: _onSearchSubmitted,
                                  decoration: InputDecoration(
                                    hintText: 'Search capsules...',
                                    prefixIcon: const Icon(Icons.search),
                                    suffixIcon: _searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear),
                                            onPressed: () {
                                              _searchController.clear();
                                              _onSearchCleared();
                                            },
                                          )
                                        : null,
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
                      ),
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

 // when user presses search key
  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      context.read<CapsuleProvider>().searchCapsules(query.trim());
    }
  }

  /// Handles clearing search
  void _onSearchCleared() {
    context.read<CapsuleProvider>().searchCapsules('');
    setState(() {}); // Refresh to hide clear button
  }

  /// Shows filter bottom sheet
  void _showFilterSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer<CapsuleProvider>(
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
                'Filter Capsules',
                style: AppTypography.getHeadline(isDark),
              ),
              SizedBox(height: 4.w),
              
              // Status filters
              Text(
                'Status',
                style: AppTypography.getTitle(isDark),
              ),
              SizedBox(height: 2.w),
              
              ...provider.getAllStatuses().map((status) => 
                _buildStatusFilterOption(status, provider, isDark)
              ).toList(),
              
              SizedBox(height: 4.w),
              
              // Clear filters button
              if (provider.selectedStatuses.isNotEmpty || provider.searchQuery.isNotEmpty)
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

  /// Builds individual status filter option
  Widget _buildStatusFilterOption(
    String status,
    CapsuleProvider provider,
    bool isDark,
  ) {
    final isSelected = provider.selectedStatuses.contains(status.toLowerCase());
    final statusIcon = _getStatusIcon(status);
    
    return Container(
      margin: EdgeInsets.only(bottom: 2.w),
      child: InkWell(
        onTap: () {
          final currentStatuses = List<String>.from(provider.selectedStatuses);
          final statusLower = status.toLowerCase();
          
          if (isSelected) {
            currentStatuses.remove(statusLower);
          } else {
            currentStatuses.add(statusLower);
          }
          
          provider.filterByStatus(currentStatuses);
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
                  statusIcon,
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
                      status.toUpperCase(),
                      style: AppTypography.getBody(isDark).copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.spaceBlue
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    Text(
                      _getStatusDescription(status),
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

  /// Gets icon for capsule status
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.check_circle;
      case 'retired':
        return Icons.history;
      case 'destroyed':
        return Icons.dangerous;
      case 'unknown':
        return Icons.help_outline;
      default:
        return Icons.info_outline;
    }
  }

  /// Gets description for capsule status
  String _getStatusDescription(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Currently operational';
      case 'retired':
        return 'No longer in service';
      case 'destroyed':
        return 'Lost or destroyed';
      case 'unknown':
        return 'Status not confirmed';
      default:
        return 'Status information';
    }
  }

  /// Builds the capsule content based on view type
  Widget _buildCapsuleContent(CapsuleProvider provider, bool isDark) {
    if (_isGridView) {
      return SliverPadding(
        padding: EdgeInsets.only(
          left: AppSpacing.m,
          right: AppSpacing.m,
          bottom: 10.h, // Add bottom padding to avoid bottom nav bar
        ),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: AppSpacing.s,
            mainAxisSpacing: AppSpacing.s,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= provider.capsules.length) {
                return provider.isLoading
                    ? Container(
                        margin: EdgeInsets.all(AppSpacing.s),
                        padding: AppSpacing.paddingM,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.spaceBlue),
                              strokeWidth: 2,
                            ),
                            AppSpacing.gapVerticalXS,
                            Text(
                              'Loading more capsules...',
                              style: AppTypography.getCaption(isDark).copyWith(
                                fontWeight: AppTypography.medium,
                              ),
                            ),
                          ],
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
      return SliverPadding(
        padding: EdgeInsets.only(bottom: 10.h), // Add bottom padding to avoid bottom nav bar
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= provider.capsules.length) {
              return provider.isLoading
                  ? Container(
                      height: 12.h,
                      margin: EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
                      padding: AppSpacing.paddingM,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.spaceBlue),
                            strokeWidth: 2,
                          ),
                          AppSpacing.gapHorizontalM,
                          Text(
                            'Loading more capsules...',
                            style: AppTypography.getBody(isDark).copyWith(
                              fontWeight: AppTypography.medium,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink();
            }
            return _buildCapsuleListCard(provider.capsules[index], isDark);
          },
          childCount: provider.capsules.length + (provider.isLoading ? 1 : 0),
          ),
        ),
      );
    }
  }

  /// Builds capsule grid card with settings screen matching design
  Widget _buildCapsuleGridCard(CapsuleEntity capsule, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.xs),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToCapsuleDetail(capsule),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
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
                    style: AppTypography.captionDark.copyWith(
                      color: Colors.white,
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                ),
                SizedBox(height: 2.w),
                Text(
                  capsule.serial ?? 'Unknown Serial',
                  style: AppTypography.getTitle(isDark),
                ),
                SizedBox(height: 1.w),
                Text(
                  capsule.type ?? 'Unknown Type',
                  style: AppTypography.getBody(isDark),
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
                    Text(
                      '${capsule.reuseCount ?? 0} flights',
                      style: AppTypography.getCaption(isDark),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds capsule list card with settings screen matching design
  Widget _buildCapsuleListCard(CapsuleEntity capsule, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 2.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToCapsuleDetail(capsule),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                width: 0.5,
              ),
            ),
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
                  style: AppTypography.getTitle(isDark),
                ),
                SizedBox(height: 1.w),
                Text(
                  capsule.type ?? 'Unknown Type',
                  style: AppTypography.getBody(isDark),
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
                        style: AppTypography.getCaption(isDark),
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
      ), ))));
  }

  /// Navigates to capsule detail screen
  void _navigateToCapsuleDetail(CapsuleEntity capsule) {
    Get.to(
      () => CapsuleDetailScreen(capsule: capsule),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }
}
