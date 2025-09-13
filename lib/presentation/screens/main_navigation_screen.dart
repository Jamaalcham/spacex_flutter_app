import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';

import '../../core/utils/colors.dart';
import '../../core/utils/app_theme.dart';
import '../providers/mission_provider.dart';
import '../providers/rocket_provider.dart';
import '../providers/launch_provider.dart';
import '../providers/theme_provider.dart';
import 'home_screen.dart';
import 'missions_screen.dart';
import 'rockets_screen.dart';
import 'launches_screen.dart';

/// Main Navigation Screen with Bottom Navigation Bar
/// 
/// Provides navigation between 4 main sections:
/// - Home
/// - Missions
/// - Rockets  
/// - Launches (includes Launchpads and Landpads)
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MissionsScreen(),
    const RocketsScreen(),
    const LaunchesScreen(),
  ];

  final List<BottomNavigationBarItem> _navigationItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      activeIcon: Icon(Icons.home),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.explore),
      activeIcon: Icon(Icons.explore),
      label: 'Missions',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.rocket),
      activeIcon: Icon(Icons.rocket),
      label: 'Rockets',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.rocket_launch),
      activeIcon: Icon(Icons.rocket_launch),
      label: 'Launches',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    
    // Initialize providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MissionProvider>().fetchMissions();
      context.read<RocketProvider>().fetchRockets();
      context.read<LaunchProvider>().fetchLaunches();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Scaffold(
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: const [
              HomeScreen(),
              MissionsScreen(),
              RocketsScreen(),
              LaunchesScreen(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              gradient: isDark 
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF1E293B),
                        Color(0xFF0F172A),
                      ],
                    )
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFF8FAFC),
                      ],
                    ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : Colors.grey).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppColors.cosmicBlue,
              unselectedItemColor: isDark 
                  ? AppColors.darkTextSecondary 
                  : AppColors.lightTextSecondary,
              selectedFontSize: 12.sp,
              unselectedFontSize: 10.sp,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
              items: [
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: AppTheme.fastAnimation,
                    padding: EdgeInsets.all(_currentIndex == 0 ? 1.w : 0),
                    decoration: _currentIndex == 0
                        ? BoxDecoration(
                            gradient: AppColors.spaceGradient,
                            borderRadius: BorderRadius.circular(8),
                          )
                        : null,
                    child: Icon(
                      Icons.home_outlined,
                      size: _currentIndex == 0 ? 6.w : 5.5.w,
                      color: _currentIndex == 0 ? Colors.white : null,
                    ),
                  ),
                  activeIcon: Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      gradient: AppColors.spaceGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.home,
                      size: 6.w,
                      color: Colors.white,
                    ),
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: AppTheme.fastAnimation,
                    padding: EdgeInsets.all(_currentIndex == 1 ? 1.w : 0),
                    decoration: _currentIndex == 1
                        ? BoxDecoration(
                            gradient: AppColors.nebulaGradient,
                            borderRadius: BorderRadius.circular(8),
                          )
                        : null,
                    child: Icon(
                      Icons.explore_outlined,
                      size: _currentIndex == 1 ? 6.w : 5.5.w,
                      color: _currentIndex == 1 ? Colors.white : null,
                    ),
                  ),
                  activeIcon: Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      gradient: AppColors.nebulaGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.explore,
                      size: 6.w,
                      color: Colors.white,
                    ),
                  ),
                  label: 'Missions',
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: AppTheme.fastAnimation,
                    padding: EdgeInsets.all(_currentIndex == 2 ? 1.w : 0),
                    decoration: _currentIndex == 2
                        ? BoxDecoration(
                            gradient: AppColors.rocketGradient,
                            borderRadius: BorderRadius.circular(8),
                          )
                        : null,
                    child: Icon(
                      Icons.rocket_outlined,
                      size: _currentIndex == 2 ? 6.w : 5.5.w,
                      color: _currentIndex == 2 ? Colors.white : null,
                    ),
                  ),
                  activeIcon: Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      gradient: AppColors.rocketGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.rocket,
                      size: 6.w,
                      color: Colors.white,
                    ),
                  ),
                  label: 'Rockets',
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: AppTheme.fastAnimation,
                    padding: EdgeInsets.all(_currentIndex == 3 ? 1.w : 0),
                    decoration: _currentIndex == 3
                        ? BoxDecoration(
                            gradient: AppColors.galaxyGradient,
                            borderRadius: BorderRadius.circular(8),
                          )
                        : null,
                    child: Icon(
                      Icons.rocket_launch_outlined,
                      size: _currentIndex == 3 ? 6.w : 5.5.w,
                      color: _currentIndex == 3 ? Colors.white : null,
                    ),
                  ),
                  activeIcon: Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      gradient: AppColors.galaxyGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.rocket_launch,
                      size: 6.w,
                      color: Colors.white,
                    ),
                  ),
                  label: 'Launches',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
