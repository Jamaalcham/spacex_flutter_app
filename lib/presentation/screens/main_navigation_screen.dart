import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/utils/colors.dart';
import '../../core/utils/app_theme.dart';
import '../../core/utils/localization/language_constants.dart';
import '../providers/theme_provider.dart';
import 'home_screen.dart';
import 'capsules_screen.dart';
import 'rockets_screen.dart';
import 'launches_screen.dart';
import 'settings_screen.dart';

// Main Navigation Screen with Bottom Navigation Bar
// - Home
// - Capsules
// - Rockets
// - Launches (includes Launchpads and Landpads)
// - Settings
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late PageController _pageController;
  final Set<int> _visitedScreens = {0}; // Home screen is visited by default

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    
    // Removed preloading - data will be fetched when screens are visited (lazy loading)
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _visitedScreens.add(index); // Mark screen as visited for lazy loading
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: [
              _buildScreen(0, const HomeScreen()),
              _buildScreen(1, const CapsulesScreen()),
              _buildScreen(2, const RocketsScreen()),
              _buildScreen(3, const LaunchesScreen()),
              _buildScreen(4, const SettingsScreen()),
            ],
          ),
          bottomNavigationBar: _buildBottomNavigationBar(isDark),
        );
      },
    );
  }

  /// Builds the bottom navigation bar with theme-aware styling
  Widget _buildBottomNavigationBar(bool isDark) {
    return Container(
      decoration: _buildNavBarDecoration(isDark),
      child: Theme(
        data: Theme.of(context).copyWith(
          bottomNavigationBarTheme: _buildNavBarTheme(isDark),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: _buildNavBarItems(isDark),
        ),
      ),
    );
  }

  /// Creates decoration for navigation bar
  BoxDecoration _buildNavBarDecoration(bool isDark) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark 
            ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
            : [const Color(0xFFFFFFFF), const Color(0xFFF8FAFC)],
      ),
      boxShadow: [
        BoxShadow(
          color: (isDark ? Colors.black : Colors.grey).withValues(alpha: 0.3),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ],
    );
  }

  /// Creates theme for navigation bar
  BottomNavigationBarThemeData _buildNavBarTheme(bool isDark) {
    return BottomNavigationBarThemeData(
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.grey.shade200 : AppColors.spaceBlue,
        fontSize: 10.sp,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 10.sp,
      ),
      selectedItemColor: isDark ? Colors.white : AppColors.spaceBlue,
      unselectedItemColor: isDark 
          ? AppColors.darkTextSecondary 
          : AppColors.lightTextSecondary,
    );
  }

  /// Creates all navigation bar items
  List<BottomNavigationBarItem> _buildNavBarItems(bool isDark) {
    final items = [
      const _NavItem(
        index: 0,
        icon: HugeIcons.strokeRoundedHome01,
        label: 'home',
        isHugeIcon: true,
      ),
      const _NavItem(
        index: 1,
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore,
        label: 'capsules',
      ),
      const _NavItem(
        index: 2,
        icon: Icons.rocket_outlined,
        activeIcon: Icons.rocket,
        label: 'rockets',
      ),
      const _NavItem(
        index: 3,
        icon: Icons.rocket_launch_outlined,
        activeIcon: Icons.rocket_launch,
        label: 'launches',
      ),
      const _NavItem(
        index: 4,
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: 'settings',
      ),
    ];

    return items.map((item) => _buildNavBarItem(item, isDark)).toList();
  }

  /// Builds individual navigation bar item
  BottomNavigationBarItem _buildNavBarItem(_NavItem item, bool isDark) {
    return BottomNavigationBarItem(
      icon: _buildNavIcon(item, isDark, false),
      activeIcon: _buildNavIcon(item, isDark, true),
      label: getTranslated(context, item.label),
    );
  }

  /// Builds navigation icon with animation and styling
  Widget _buildNavIcon(_NavItem item, bool isDark, bool isActive) {
    final isSelected = _currentIndex == item.index;
    final shouldShowActive = isActive && isSelected;
    
    return AnimatedContainer(
      duration: AppTheme.fastAnimation,
      padding: EdgeInsets.all(isSelected ? 1.w : 0),
      decoration: isSelected ? _buildActiveDecoration() : null,
      child: item.isHugeIcon
          ? HugeIcon(
              icon: item.icon,
              size: isSelected ? 6.w : 5.5.w,
              color: isSelected 
                  ? Colors.white 
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            )
          : Icon(
              shouldShowActive && item.activeIcon != null 
                  ? item.activeIcon as IconData
                  : item.icon as IconData,
              size: isSelected ? 6.w : 5.5.w,
              color: isSelected ? Colors.white : null,
            ),
    );
  }

  /// Creates decoration for active navigation item
  BoxDecoration _buildActiveDecoration() {
    return BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(8),
    );
  }

  /// Builds screen with lazy loading - only renders if visited
  Widget _buildScreen(int index, Widget screen) {
    if (_visitedScreens.contains(index)) {
      return screen;
    }
    // Return empty container for unvisited screens to prevent initialization
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Data class for navigation item configuration
class _NavItem {
  final int index;
  final dynamic icon;
  final dynamic activeIcon;
  final String label;
  final bool isHugeIcon;

  const _NavItem({
    required this.index,
    required this.icon,
    this.activeIcon,
    required this.label,
    this.isHugeIcon = false,
  });
}
