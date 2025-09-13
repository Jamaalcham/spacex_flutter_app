import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/utils/colors.dart';
import '../../../core/utils/localization/language_constants.dart';

/// Reusable error widget with SpaceX theme
/// 
/// Provides consistent error display throughout the app with
/// customizable messages, actions, and styling options.
class ErrorDisplayWidget extends StatelessWidget {
  /// Error message to display
  final String? message;
  
  /// Optional error details for debugging
  final String? details;
  
  /// Callback function for retry action
  final VoidCallback? onRetry;
  
  /// Custom retry button text
  final String? retryText;
  
  /// Whether to show the retry button
  final bool showRetry;
  
  /// Custom icon to display with the error
  final IconData? icon;
  
  /// Error type for different styling
  final ErrorType type;

  const ErrorDisplayWidget({
    super.key,
    this.message,
    this.details,
    this.onRetry,
    this.retryText,
    this.showRetry = true,
    this.icon,
    this.type = ErrorType.general,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getErrorColor().withOpacity(0.1),
              ),
              child: Icon(
                icon ?? _getErrorIcon(),
                size: 10.w,
                color: _getErrorColor(),
              ),
            ),
            
            SizedBox(height: 3.h),
            
            // Error title
            Text(
              _getErrorTitle(context),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimary : AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 1.h),
            
            // Error message
            Text(
              message ?? _getDefaultMessage(context),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondary : AppColors.textLightSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Error details (only in debug mode)
            if (details != null && _isDebugMode()) ...[
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Debug Info: $details',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            
            // Retry button
            if (showRetry && onRetry != null) ...[
              SizedBox(height: 4.h),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(
                  retryText ?? getTranslated(context, 'retry') ?? 'Retry',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getErrorColor(),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 1.5.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Gets appropriate color based on error type
  Color _getErrorColor() {
    switch (type) {
      case ErrorType.network:
        return AppColors.warning;
      case ErrorType.server:
        return AppColors.error;
      case ErrorType.notFound:
        return AppColors.textSecondary;
      case ErrorType.general:
      default:
        return AppColors.error;
    }
  }

  /// Gets appropriate icon based on error type
  IconData _getErrorIcon() {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.server:
        return Icons.error_outline;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.general:
      default:
        return Icons.error_outline;
    }
  }

  /// Gets error title based on type
  String _getErrorTitle(BuildContext context) {
    switch (type) {
      case ErrorType.network:
        return getTranslated(context, 'no_internet') ?? 'No Internet Connection';
      case ErrorType.server:
        return getTranslated(context, 'error_server') ?? 'Server Error';
      case ErrorType.notFound:
        return getTranslated(context, 'no_results') ?? 'No Results Found';
      case ErrorType.general:
      default:
        return getTranslated(context, 'error') ?? 'Something Went Wrong';
    }
  }

  /// Gets default error message based on type
  String _getDefaultMessage(BuildContext context) {
    switch (type) {
      case ErrorType.network:
        return getTranslated(context, 'error_no_internet') ?? 
               'Please check your internet connection and try again.';
      case ErrorType.server:
        return getTranslated(context, 'error_server_unavailable') ?? 
               'The server is temporarily unavailable. Please try again later.';
      case ErrorType.notFound:
        return getTranslated(context, 'no_data') ?? 
               'No data available at the moment.';
      case ErrorType.general:
      default:
        return getTranslated(context, 'error_try_again') ?? 
               'An unexpected error occurred. Please try again.';
    }
  }

  /// Checks if app is in debug mode
  bool _isDebugMode() {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }
}

/// Types of errors for different styling and messaging
enum ErrorType {
  general,
  network,
  server,
  notFound,
}

/// Specialized error widget for network issues
class NetworkErrorWidget extends ErrorDisplayWidget {
  const NetworkErrorWidget({
    super.key,
    super.onRetry,
    super.message,
  }) : super(type: ErrorType.network);
}

/// Specialized error widget for server issues
class ServerErrorWidget extends ErrorDisplayWidget {
  const ServerErrorWidget({
    super.key,
    super.onRetry,
    super.message,
  }) : super(type: ErrorType.server);
}

/// Specialized error widget for no data/not found scenarios
class NoDataWidget extends ErrorDisplayWidget {
  const NoDataWidget({
    super.key,
    super.message,
    super.onRetry,
  }) : super(
          type: ErrorType.notFound,
          showRetry: false,
        );
}

/// Compact error widget for inline display
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const InlineErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(3.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 5.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(width: 2.w),
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              color: AppColors.error,
              iconSize: 5.w,
            ),
          ],
        ],
      ),
    );
  }
}
