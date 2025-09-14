import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/utils/colors.dart';

/// Network Error Widget
/// 
/// A reusable widget for displaying network connection errors
/// with retry functionality and SpaceX theming
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const NetworkErrorWidget({
    Key? key,
    this.onRetry,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 50.h,
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: AppColors.launchRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.w),
              border: Border.all(
                color: AppColors.launchRed.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              size: 10.w,
              color: AppColors.launchRed,
            ),
          ),
          
          SizedBox(height: 4.h),
          
          Text(
            'Connection Lost',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          
          SizedBox(height: 1.h),
          
          Text(
            message ?? 'Unable to connect to SpaceX servers.\nCheck your internet connection and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? Colors.white70 : Colors.black54,
              height: 1.4,
            ),
          ),
          
          SizedBox(height: 4.h),
          
          if (onRetry != null)
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh_rounded, size: 5.w),
              label: Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rocketOrange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 6.w,
                  vertical: 2.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.w),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
