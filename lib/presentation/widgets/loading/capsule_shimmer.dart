import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../../core/utils/spacing.dart';

// Shimmer loading widget for capsule cards
class CapsuleShimmer extends StatelessWidget {
  final bool isGridView;
  
  const CapsuleShimmer({
    super.key,
    this.isGridView = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: isGridView ? _buildGridShimmer() : _buildListShimmer(),
    );
  }

  Widget _buildGridShimmer() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.xs),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Status indicator shimmer
          Container(
            width: 20.w,
            height: 3.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: 2.w),
          
          // Serial number shimmer
          Container(
            width: 25.w,
            height: 4.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 1.w),
          
          // Type shimmer
          Container(
            width: 18.w,
            height: 3.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 2.w),
          
          // Flight count shimmer
          Row(
            children: [
              Container(
                width: 3.w,
                height: 3.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 1.w),
              Container(
                width: 15.w,
                height: 2.5.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListShimmer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 2.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icon shimmer
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3.w),
            ),
          ),
          SizedBox(width: 4.w),
          
          // Content shimmer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Serial shimmer
                Container(
                  width: 40.w,
                  height: 4.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 1.w),
                
                // Type shimmer
                Container(
                  width: 30.w,
                  height: 3.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 2.w),
                
                // Flight info shimmer
                Container(
                  width: 50.w,
                  height: 2.5.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          
          // Arrow shimmer
          Container(
            width: 4.w,
            height: 4.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

/// Grid of shimmer capsule cards
class CapsuleGridShimmer extends StatelessWidget {
  const CapsuleGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.m,
        right: AppSpacing.m,
        bottom: 10.h,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: AppSpacing.s,
          mainAxisSpacing: AppSpacing.s,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => const CapsuleShimmer(isGridView: true),
      ),
    );
  }
}

// List of shimmer capsule cards
class CapsuleListShimmer extends StatelessWidget {
  const CapsuleListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        itemBuilder: (context, index) => const CapsuleShimmer(isGridView: false),
      ),
    );
  }
}
