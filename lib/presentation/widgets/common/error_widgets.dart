import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/utils/colors.dart';
import '../../../core/utils/app_theme.dart';
import 'animated_components.dart';

/// Comprehensive Error Widget with retry functionality
class SpaceErrorWidget extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final bool showRetryButton;
  final Widget? customAction;

  const SpaceErrorWidget({
    super.key,
    this.title = 'Houston, We Have a Problem',
    required this.message,
    this.onRetry,
    this.icon,
    this.showRetryButton = true,
    this.customAction,
  });

  @override
  State<SpaceErrorWidget> createState() => _SpaceErrorWidgetState();
}

class _SpaceErrorWidgetState extends State<SpaceErrorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.normalAnimation,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(6.w),
                child: GlassContainer(
                  isDark: isDark,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Error Icon
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.icon ?? Icons.error_outline,
                          color: AppColors.errorRed,
                          size: 12.w,
                        ),
                      ),
                      
                      SizedBox(height: 3.h),
                      
                      // Title
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      SizedBox(height: 2.h),
                      
                      // Message
                      Text(
                        widget.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      SizedBox(height: 4.h),
                      
                      // Action Buttons
                      if (widget.customAction != null)
                        widget.customAction!
                      else if (widget.showRetryButton && widget.onRetry != null)
                        SpaceButton(
                          text: 'Try Again',
                          icon: Icons.refresh,
                          onPressed: widget.onRetry,
                          gradient: AppColors.rocketGradient,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Network Error Widget
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SpaceErrorWidget(
      title: 'Connection Lost',
      message: 'Unable to connect to SpaceX servers.\nCheck your internet connection and try again.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
    );
  }
}

/// Empty State Widget
class EmptyStateWidget extends StatefulWidget {
  final String title;
  final String message;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionText;
  final Widget? illustration;

  const EmptyStateWidget({
    super.key,
    this.title = 'Nothing Here Yet',
    required this.message,
    this.icon,
    this.onAction,
    this.actionText,
    this.illustration,
  });

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Floating Illustration or Icon
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: widget.illustration ?? Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.cosmicBlue : AppColors.nebulaBlue).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon ?? Icons.explore_off,
                      color: isDark ? AppColors.cosmicBlue : AppColors.stellarBlue,
                      size: 15.w,
                    ),
                  ),
                );
              },
            ),
            
            SizedBox(height: 4.h),
            
            // Title
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 2.h),
            
            // Message
            Text(
              widget.message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (widget.onAction != null && widget.actionText != null) ...[
              SizedBox(height: 4.h),
              SpaceButton(
                text: widget.actionText!,
                onPressed: widget.onAction,
                gradient: AppColors.nebulaGradient,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading State Widget with Shimmer
class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final bool showMessage;

  const LoadingStateWidget({
    super.key,
    this.message,
    this.showMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Loading Indicator
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              gradient: AppColors.spaceGradient,
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 8.w,
              height: 8.w,
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
          
          if (showMessage) ...[
            SizedBox(height: 3.h),
            Text(
              message ?? 'Loading mission data...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Snackbar Helper for consistent error/success messages
class SpaceSnackBar {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        margin: EdgeInsets.all(4.w),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        margin: EdgeInsets.all(4.w),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.infoBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        margin: EdgeInsets.all(4.w),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
