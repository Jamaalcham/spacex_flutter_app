import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

// Reusable Custom App Bar Widget
// Supports different configurations for various screen types.
class CustomAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final VoidCallback? onRefresh;
  final VoidCallback? onSearch;
  final VoidCallback? onFilter;
  final VoidCallback? onViewToggle;
  final bool? isGridView;
  final bool showSearch;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = false,
    this.onRefresh,
    this.onSearch,
    this.onFilter,
    this.onViewToggle,
    this.isGridView,
    this.showSearch = false,
  });

  /// Factory constructor for Settings screen
  factory CustomAppBar.settings() {
    return const CustomAppBar(
      title: 'Settings',
      centerTitle: true,
    );
  }

  /// Factory constructor for Launches screen
  factory CustomAppBar.launches({
    VoidCallback? onRefresh,
  }) {
    return CustomAppBar(
      title: 'Explorer',
      onRefresh: onRefresh,
    );
  }

  /// Factory constructor for Capsules screen
  factory CustomAppBar.capsules({
    required VoidCallback onSearch,
    required VoidCallback onFilter,
    required VoidCallback onViewToggle,
    required bool isGridView,
  }) {
    return CustomAppBar(
      title: 'Capsules',
      onSearch: onSearch,
      onFilter: onFilter,
      onViewToggle: onViewToggle,
      isGridView: isGridView,
    );
  }

  /// Factory constructor for Rockets screen
  factory CustomAppBar.rockets({
    required VoidCallback onSearch,
    required VoidCallback onFilter,
  }) {
    return CustomAppBar(
      title: 'Rockets',
      onSearch: onSearch,
      onFilter: onFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 8.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        mainAxisAlignment: centerTitle ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          // Title
          if (!centerTitle) ...[
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const Spacer(),
          ] else ...[
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
          
          // Action buttons
          if (!centerTitle) ..._buildActionButtons(isDark),
          
          // Custom actions
          if (actions != null) ...actions!,
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons(bool isDark) {
    List<Widget> buttons = [];
    
    // Search button
    if (onSearch != null) {
      buttons.add(
        IconButton(
          onPressed: onSearch,
          icon: Icon(
            Icons.search,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      );
    }
    
    // View toggle button
    if (onViewToggle != null && isGridView != null) {
      buttons.add(
        IconButton(
          onPressed: onViewToggle,
          icon: Icon(
            isGridView! ? Icons.view_list : Icons.grid_view,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      );
    }
    
    // Filter button
    if (onFilter != null) {
      buttons.add(
        IconButton(
          onPressed: onFilter,
          icon: Icon(
            Icons.filter_list,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      );
    }
    
    // Refresh button
    if (onRefresh != null) {
      buttons.add(
        IconButton(
          onPressed: onRefresh,
          icon: Icon(
            Icons.refresh,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      );
    }
    
    return buttons;
  }
}
