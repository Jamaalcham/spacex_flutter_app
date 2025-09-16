import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../../core/utils/spacing.dart';

/// Shimmer loading widget for rocket cards
class RocketShimmer extends StatelessWidget {
  final bool isGridView;
  
  const RocketShimmer({
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
            width: 18.w,
            height: 3.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: 2.w),
          
          // Rocket name shimmer
          Container(
            width: 28.w,
            height: 4.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 1.w),
          
          // Company shimmer
          Container(
            width: 20.w,
            height: 3.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 2.w),
          
          // Stats shimmer
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
                width: 12.w,
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
                // Rocket name shimmer
                Container(
                  width: 45.w,
                  height: 4.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 1.w),
                
                // Company shimmer
                Container(
                  width: 25.w,
                  height: 3.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 2.w),
                
                // Stats shimmer
                Container(
                  width: 55.w,
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

/// Grid of shimmer rocket cards (for regular widget contexts)
class RocketGridShimmer extends StatelessWidget {
  const RocketGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.m),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: AppSpacing.s,
          mainAxisSpacing: AppSpacing.s,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => const RocketShimmer(isGridView: true),
      ),
    );
  }
}

/// List of shimmer rocket cards (for regular widget contexts)
class RocketListShimmer extends StatelessWidget {
  const RocketListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        itemBuilder: (context, index) => const RocketShimmer(isGridView: false),
      ),
    );
  }
}

/// Sliver grid of shimmer rocket cards (for CustomScrollView contexts)
class RocketGridSliverShimmer extends StatelessWidget {
  const RocketGridSliverShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.all(AppSpacing.m),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: AppSpacing.s,
          mainAxisSpacing: AppSpacing.s,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => const RocketShimmer(isGridView: true),
          childCount: 6,
        ),
      ),
    );
  }
}

/// Sliver list of shimmer rocket cards (for CustomScrollView contexts)
class RocketListSliverShimmer extends StatelessWidget {
  const RocketListSliverShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(bottom: 10.h),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => const RocketShimmer(isGridView: false),
          childCount: 8, // Show 8 shimmer items
        ),
      ),
    );
  }
}
