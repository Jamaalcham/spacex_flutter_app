import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/utils/colors.dart';
import '../../../core/utils/app_theme.dart';
import '../../../domain/entities/launch_entity.dart';
import 'animated_components.dart';

/// Enhanced SpaceX card widget with animations and modern design
class SpaceXCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final VoidCallback? onTap;
  final Widget? child;
  final Widget? leading;
  final Widget? trailing;
  /// Custom background color (defaults to theme surface color)
  final Color? backgroundColor;
  
  /// Custom border radius (defaults to 12.0)
  final double borderRadius;
  
  /// Card elevation (defaults to 4.0)
  final double elevation;
  
  /// Custom padding inside the card
  final EdgeInsetsGeometry? padding;
  
  /// Custom margin around the card
  final EdgeInsetsGeometry? margin;
  
  /// Whether to show a loading shimmer effect
  final bool isLoading;
  
  /// Whether the card is selected/highlighted
  final bool isSelected;
  
  /// Custom height for the card
  final double? height;
  
  /// Custom width for the card
  final double? width;

  const SpaceXCard({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.child,
    this.leading,
    this.trailing,
    this.onTap,
    this.backgroundColor,
    this.borderRadius = 12.0,
    this.elevation = 4.0,
    this.padding,
    this.margin,
    this.isLoading = false,
    this.isSelected = false,
    this.height,
    this.width,
  });

  @override
  State<SpaceXCard> createState() => _SpaceXCardState();
}

class _SpaceXCardState extends State<SpaceXCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      height: widget.height,
      width: widget.width,
      margin: widget.margin ?? EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
      child: Material(
        elevation: widget.elevation,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        color: widget.backgroundColor ?? 
               (widget.isSelected 
                ? AppColors.primary.withValues(alpha:0.1)
                : (isDark ? AppColors.darkSurface : AppColors.lightSurface)),
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onTap,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Container(
            padding: widget.padding ?? EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: widget.isSelected 
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.isLoading ? _buildLoadingContent() : _buildContent(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the main content of the card
  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    
    return Flexible(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row with leading, title/subtitle, and trailing
            if (widget.leading != null || widget.title != null || widget.trailing != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Leading widget
                  if (widget.leading != null) ...[
                    widget.leading!,
                    SizedBox(width: 2.w),
                  ],
                  
                  // Title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.title != null)
                          Text(
                            widget.title!,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                              color: theme.brightness == Brightness.dark 
                                  ? AppColors.textPrimary 
                                  : AppColors.textLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (widget.subtitle != null) ...[
                          SizedBox(height: 0.3.h),
                          Text(
                            widget.subtitle!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 9.sp,
                              color: theme.brightness == Brightness.dark 
                                  ? AppColors.textSecondary 
                                  : AppColors.textLightSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Trailing widget
                  if (widget.trailing != null) ...[
                    SizedBox(width: 2.w),
                    widget.trailing!,
                  ],
                ],
              ),
            
            // Custom child content
            if (widget.child != null) ...[
              if (widget.title != null || widget.subtitle != null) SizedBox(height: 1.h),
              widget.child!,
            ],
          ],
        ),
      ),
    );
  }

  /// Builds loading shimmer content
  Widget _buildLoadingContent() {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Shimmer title
          Container(
            height: 2.h,
            width: 60.w,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha:0.3),
              borderRadius: BorderRadius.circular(1.w),
            ),
          ),
          SizedBox(height: 0.8.h),
          
          // Shimmer subtitle
          Container(
            height: 1.5.h,
            width: 80.w,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(1.w),
            ),
          ),
          SizedBox(height: 0.4.h),
          
          Container(
            height: 1.5.h,
            width: 40.w,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(1.w),
            ),
          ),
        ],
      ),
    );
  }
}

/// Specialized card for displaying mission information
class MissionCard extends StatelessWidget {
  final String missionName;
  final String? description;
  final List<String> manufacturers;
  final VoidCallback? onTap;

  const MissionCard({
    super.key,
    required this.missionName,
    this.description,
    required this.manufacturers,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SpaceXCard(
      title: missionName,
      subtitle: description,
      onTap: onTap,
      leading: Container(
        width: 12.w,
        height: 12.w,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (manufacturers.isNotEmpty) ...[
            Text(
              'Manufacturers: ${manufacturers.join(', ')}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// Specialized card for displaying rocket information
class RocketCard extends StatelessWidget {
  final String rocketName;
  final String? description;
  final bool isActive;
  final int? successRate;
  final int? cost;
  final VoidCallback? onTap;

  const RocketCard({
    super.key,
    required this.rocketName,
    this.description,
    required this.isActive,
    this.successRate,
    this.cost,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SpaceXCard(
      title: rocketName,
      subtitle: description,
      onTap: onTap,
      leading: Container(
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isActive ? AppColors.spaceGradient : null,
          color: isActive ? null : Colors.grey,
        ),
        child: Icon(
          Icons.rocket,
          color: Colors.white,
          size: 5.w,
        ),
      ),
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.3.h),
        decoration: BoxDecoration(
          color: isActive ? AppColors.success : Colors.grey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          isActive ? 'Active' : 'Retired',
          style: TextStyle(
            color: Colors.white,
            fontSize: 8.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (successRate != null || cost != null) ...[
              SizedBox(height: 1.h),
              Row(
                children: [
                  if (successRate != null) ...[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Success Rate',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 8.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.2.h),
                          Text(
                            '${successRate!}%',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                              fontSize: 9.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (successRate != null && cost != null) SizedBox(width: 2.w),
                  if (cost != null) ...[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Cost/Launch',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 8.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.2.h),
                          Text(
                            '\$${(cost! / 1000000).toStringAsFixed(1)}M',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                              fontSize: 9.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Specialized card for displaying launch information
class LaunchCard extends StatelessWidget {
  final LaunchEntity launch;
  final VoidCallback? onTap;

  const LaunchCard({
    super.key,
    required this.launch,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SpaceXCard(
      title: launch.missionName,
      subtitle: launch.details ?? 'No details available',
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Launch status and date
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: launch.success == true 
                      ? Colors.green.withValues(alpha:0.2)
                      : launch.success == false
                          ? Colors.red.withValues(alpha:0.2)
                          : Colors.orange.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: launch.success == true 
                        ? Colors.green
                        : launch.success == false
                            ? Colors.red
                            : Colors.orange,
                  ),
                ),
                child: Text(
                  launch.success == true 
                      ? 'Success'
                      : launch.success == false
                          ? 'Failed'
                          : 'Upcoming',
                  style: TextStyle(
                    color: launch.success == true 
                        ? Colors.green
                        : launch.success == false
                            ? Colors.red
                            : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
                  ),
                ),
              ),
              const Spacer(),
              if (launch.dateUtc != null)
                Text(
                  _formatDate(launch.dateUtc!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10.sp,
                  ),
                ),
            ],
          ),
          
          SizedBox(height: 1.h),
          
          // Flight number and rocket info
          if (launch.flightNumber != null) ...[
            Row(
              children: [
                Icon(
                  Icons.flight,
                  color: AppColors.textSecondary,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Flight #${launch.flightNumber}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 0.5.h),
          ],
          
          // Launch site
          if (launch.launchSite != null) ...[
            Row(
              children: [
                Icon(
                  Icons.launch,
                  color: AppColors.textSecondary,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Launch Site: ${launch.launchSite!.displayName}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d from now';
    } else if (difference.inDays < 0) {
      return '${-difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h from now';
    } else if (difference.inHours < 0) {
      return '${-difference.inHours}h ago';
    } else {
      return 'Today';
    }
  }
}
