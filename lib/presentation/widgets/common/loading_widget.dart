import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/utils/colors.dart';

/// Reusable loading widget with SpaceX theme
/// 
/// Provides various loading states including shimmer effects,
/// circular progress indicators, and custom loading animations.
class LoadingWidget extends StatelessWidget {
  /// Type of loading animation to display
  final LoadingType type;
  
  /// Custom message to display with the loading indicator
  final String? message;
  
  /// Size of the loading indicator
  final LoadingSize size;
  
  /// Custom color for the loading indicator
  final Color? color;

  const LoadingWidget({
    super.key,
    this.type = LoadingType.circular,
    this.message,
    this.size = LoadingSize.medium,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    switch (type) {
      case LoadingType.circular:
        return _buildCircularLoading(context, isDark);
      case LoadingType.shimmer:
        return _buildShimmerLoading(context, isDark);
      case LoadingType.rocket:
        return _buildRocketLoading(context, isDark);
      case LoadingType.dots:
        return _buildDotsLoading(context, isDark);
    }
  }

  /// Builds circular progress indicator with optional message
  Widget _buildCircularLoading(BuildContext context, bool isDark) {
    final indicatorSize = _getIndicatorSize();
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: indicatorSize,
            height: indicatorSize,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primary,
              ),
            ),
          ),
          if (message != null) ...[
            SizedBox(height: 2.h),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondary : AppColors.textLightSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Builds shimmer loading effect for list items
  Widget _buildShimmerLoading(BuildContext context, bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark 
          ? Colors.grey[800]! 
          : Colors.grey[300]!,
      highlightColor: isDark 
          ? Colors.grey[700]! 
          : Colors.grey[100]!,
      child: Column(
        children: List.generate(5, (index) => _buildShimmerItem()),
      ),
    );
  }

  /// Builds animated rocket loading indicator
  Widget _buildRocketLoading(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -20 * value),
                child: Container(
                  width: _getIndicatorSize(),
                  height: _getIndicatorSize(),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.spaceGradient,
                  ),
                  child: const Icon(
                    Icons.rocket_launch,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              );
            },
          ),
          if (message != null) ...[
            SizedBox(height: 2.h),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondary : AppColors.textLightSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Builds animated dots loading indicator
  Widget _buildDotsLoading(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 600 + (index * 200)),
                builder: (context, value, child) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 1.w),
                    width: 2.w,
                    height: 2.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (color ?? AppColors.primary).withValues(alpha:value),
                    ),
                  );
                },
              );
            }),
          ),
          if (message != null) ...[
            SizedBox(height: 2.h),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondary : AppColors.textLightSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Builds individual shimmer item
  Widget _buildShimmerItem() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 2.h,
                      width: 60.w,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      height: 1.5.h,
                      width: 40.w,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            height: 1.h,
            width: 80.w,
            color: Colors.grey,
          ),
          SizedBox(height: 0.5.h),
          Container(
            height: 1.h,
            width: 60.w,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  /// Gets indicator size based on LoadingSize enum
  double _getIndicatorSize() {
    switch (size) {
      case LoadingSize.small:
        return 8.w;
      case LoadingSize.medium:
        return 12.w;
      case LoadingSize.large:
        return 16.w;
    }
  }
}

/// Types of loading animations available
enum LoadingType {
  circular,
  shimmer,
  rocket,
  dots,
}

/// Sizes for loading indicators
enum LoadingSize {
  small,
  medium,
  large,
}

/// Specialized loading widget for list views
class ListLoadingWidget extends StatelessWidget {
  final int itemCount;

  const ListLoadingWidget({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingWidget(
      type: LoadingType.shimmer,
    );
  }
}

/// Loading widget for full screen loading states
class FullScreenLoadingWidget extends StatelessWidget {
  final String? message;
  final LoadingType type;

  const FullScreenLoadingWidget({
    super.key,
    this.message,
    this.type = LoadingType.rocket,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: LoadingWidget(
        type: type,
        message: message ?? 'Loading SpaceX data...',
        size: LoadingSize.large,
      ),
    );
  }
}
