import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';

import '../../core/utils/colors.dart';
import '../../core/utils/spacing.dart';
import '../../core/utils/typography.dart';
import '../../domain/entities/capsule_entity.dart';
import '../../domain/entities/launch_entity.dart';
import '../providers/launch_provider.dart';
import '../widgets/common/glass_background.dart';
import '../widgets/common/custom_app_bar.dart';

// Capsule Detail Screen
// Displays comprehensive information about a specific capsule including
class CapsuleDetailScreen extends StatefulWidget {
  final CapsuleEntity capsule;

  const CapsuleDetailScreen({
    super.key,
    required this.capsule,
  });

  @override
  State<CapsuleDetailScreen> createState() => _CapsuleDetailScreenState();
}

class _CapsuleDetailScreenState extends State<CapsuleDetailScreen> {
  List<LaunchEntity> _launches = [];
  bool _isLoadingLaunches = false;

  @override
  void initState() {
    super.initState();
    _fetchLaunchDetails();
  }

  // Fetch launch details for the capsule's launches
  Future<void> _fetchLaunchDetails() async {
    if (widget.capsule.launches.isEmpty) return;

    setState(() => _isLoadingLaunches = true);

    try {
      final launchProvider = context.read<LaunchProvider>();
      
      // Fetch all launches if not already loaded
      if (launchProvider.launches.isEmpty) {
        await launchProvider.fetchLaunches();
      }

      // Filter launches that match this capsule's launch IDs
      // Note: We'll use flight number as identifier since launch IDs might not match directly
      final capsuleLaunches = launchProvider.launches
          .where((launch) => widget.capsule.launches.any((launchId) => 
              launchId.contains(launch.flightNumber.toString()) || 
              launch.flightNumber.toString().contains(launchId)))
          .toList();

      setState(() {
        _launches = capsuleLaunches;
        _isLoadingLaunches = false;
      });
    } catch (e) {
      setState(() => _isLoadingLaunches = false);
      Get.snackbar(
        'Error',
        'Failed to load launch details',
        backgroundColor: AppColors.errorRed,
        colorText: Colors.white,
      );
    }
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
              _buildAppBar(isDark),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: AppSpacing.paddingHorizontalM,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSpacing.gapVerticalM,
                      
                      // Capsule Header
                      _buildCapsuleHeader(isDark),
                      AppSpacing.gapVerticalL,
                      
                      // Statistics Section
                      _buildStatisticsSection(isDark),
                      AppSpacing.gapVerticalL,
                      
                      // Status & Details Section
                      _buildStatusSection(isDark),
                      AppSpacing.gapVerticalL,
                      
                      // Launches Section
                      _buildLaunchesSection(isDark),
                      AppSpacing.gapVerticalXL,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds custom app bar
  Widget _buildAppBar(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      child: Row(
        children: [
          // Back button
          InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.8),
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: isDark ? Colors.white : Colors.black87,
                size: 20.sp,
              ),
            ),
          ),
          
          SizedBox(width: 4.w),
          
          // Title
          Expanded(
            child: Text(
              'Capsule ${widget.capsule.serial}',
              style: AppTypography.getTitle(isDark),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Share button
          InkWell(
            onTap: () => _shareCapsule(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.8),
                ),
              ),
              child: Icon(
                Icons.share,
                color: isDark ? Colors.white : Colors.black87,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shares capsule information
  void _shareCapsule() {
    Get.snackbar(
      'Share',
      'Capsule ${widget.capsule.serial} details shared!',
      backgroundColor: AppColors.spaceBlue,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  /// Build capsule header with type and serial
  Widget _buildCapsuleHeader(bool isDark) {
    return Container(
      padding: AppSpacing.paddingL,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.capsule.serial ?? 'Unknown Serial',
                      style: AppTypography.getHeadline(isDark).copyWith(
                        fontWeight: AppTypography.bold,
                      ),
                    ),
                    AppSpacing.gapVerticalXS,
                    Text(
                      widget.capsule.type ?? 'Unknown Type',
                      style: AppTypography.getBody(isDark).copyWith(
                        fontWeight: AppTypography.medium,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(widget.capsule.status),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.capsule.status?.toUpperCase() ?? 'UNKNOWN',
                  style: AppTypography.getCaption(isDark).copyWith(
                    fontWeight: AppTypography.medium,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build statistics section with reuse count and landings
  Widget _buildStatisticsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STATISTICS',
          style: AppTypography.getCaption(isDark).copyWith(
            fontWeight: AppTypography.medium,
            letterSpacing: 0.5,
          ),
        ),
        AppSpacing.gapVerticalS,
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Reuse Count',
                '${widget.capsule.reuseCount ?? 0}',
                Icons.refresh,
                isDark,
              ),
            ),
            AppSpacing.gapHorizontalS,
            Expanded(
              child: _buildStatCard(
                'Water Landings',
                '${widget.capsule.waterLandings ?? 0}',
                Icons.water,
                isDark,
              ),
            ),
          ],
        ),
        AppSpacing.gapVerticalS,
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Land Landings',
                '${widget.capsule.landLandings ?? 0}',
                Icons.landscape,
                isDark,
              ),
            ),
            AppSpacing.gapHorizontalS,
            Expanded(
              child: _buildStatCard(
                'Total Flights',
                '${widget.capsule.launches.length}',
                Icons.rocket_launch,
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build individual stat card
  Widget _buildStatCard(String title, String value, IconData icon, bool isDark) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 5.w,
                color: AppColors.spaceBlue,
              ),
              AppSpacing.gapHorizontalXS,
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.getCaption(isDark).copyWith(
                    fontWeight: AppTypography.medium,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapVerticalXS,
          Text(
            value,
            style: AppTypography.getTitle(isDark).copyWith(
              fontWeight: AppTypography.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build status and details section
  Widget _buildStatusSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DETAILS',
          style: AppTypography.getCaption(isDark).copyWith(
            fontWeight: AppTypography.medium,
            letterSpacing: 0.5,
          ),
        ),
        AppSpacing.gapVerticalS,
        Container(
          width: double.infinity,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.capsule.lastUpdate != null) ...[
                Text(
                  'Last Update',
                  style: AppTypography.getCaption(isDark).copyWith(
                    fontWeight: AppTypography.medium,
                  ),
                ),
                AppSpacing.gapVerticalXS,
                Text(
                  widget.capsule.lastUpdate!,
                  style: AppTypography.getBody(isDark),
                ),
              ] else ...[
                Text(
                  'No additional details available',
                  style: AppTypography.getBody(isDark).copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Build launches section with detailed launch information
  Widget _buildLaunchesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ASSOCIATED LAUNCHES',
          style: AppTypography.getCaption(isDark).copyWith(
            fontWeight: AppTypography.medium,
            letterSpacing: 0.5,
          ),
        ),
        AppSpacing.gapVerticalS,
        
        if (_isLoadingLaunches)
          Container(
            padding: AppSpacing.paddingL,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (_launches.isEmpty)
          Container(
            width: double.infinity,
            padding: AppSpacing.paddingL,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            child: Text(
              'No launch information available',
              style: AppTypography.getBody(isDark).copyWith(
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...(_launches.map((launch) => _buildLaunchCard(launch, isDark)).toList()),
      ],
    );
  }

  /// Build individual launch card
  Widget _buildLaunchCard(LaunchEntity launch, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.s),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  launch.missionName ?? 'Unknown Mission',
                  style: AppTypography.getBody(isDark).copyWith(
                    fontWeight: AppTypography.medium,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: launch.success == true 
                      ? AppColors.missionGreen 
                      : launch.success == false 
                          ? AppColors.errorRed 
                          : AppColors.textSecondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  launch.success == true 
                      ? 'SUCCESS' 
                      : launch.success == false 
                          ? 'FAILED' 
                          : 'UNKNOWN',
                  style: AppTypography.getCaption(isDark).copyWith(
                    fontWeight: AppTypography.medium,
                    color: Colors.white,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),
          
          if (launch.dateUtc != null) ...[
            AppSpacing.gapVerticalXS,
            Text(
              'Launch Date: ${_formatDate(launch.dateUtc.toString())}',
              style: AppTypography.getCaption(isDark),
            ),
          ],
          
          if (launch.details != null && launch.details!.isNotEmpty) ...[
            AppSpacing.gapVerticalXS,
            Text(
              launch.details!,
              style: AppTypography.getCaption(isDark),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  /// Get status color based on capsule status
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return AppColors.missionGreen;
      case 'retired':
        return AppColors.textSecondary;
      case 'destroyed':
        return AppColors.errorRed;
      case 'unknown':
      default:
        return AppColors.rocketOrange;
    }
  }

  /// Format date string for display
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
