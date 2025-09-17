import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../core/network/graphql_client.dart';
import '../../core/utils/typography.dart';
import '../../data/models/launch_model.dart';
import '../../data/models/launchpad_model.dart';
import '../../data/models/landpad_model.dart';
import '../../data/queries/launches_query.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/common/glass_background.dart';
import '../widgets/common/modern_card.dart';

/// Launch Tracker Screen with Dynamic GraphQL Data
class LaunchesScreen extends StatefulWidget {
  const LaunchesScreen({super.key});

  @override
  State<LaunchesScreen> createState() => _LaunchesScreenState();
}

class _LaunchesScreenState extends State<LaunchesScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  int _selectedTabIndex = 0;
  Timer? _countdownTimer;
  
  // Data state
  List<Launch> _pastLaunches = [];
  List<Launch> _upcomingLaunches = [];
  List<LaunchpadModel> _launchpads = [];
  List<LandpadModel> _landpads = [];
  
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Update countdown logic here
        });
      }
    });
  }
  
  /// Loads data from GraphQL API with retry logic
  Future<void> _loadData({int retryCount = 0}) async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = GraphQLService.client;
      final QueryOptions options = QueryOptions(
        document: gql(launchesQuery),
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await client.query(options);
      
      if (result.hasException) {
        // Check if it's a timeout or network error and retry
        final exceptionString = result.exception.toString().toLowerCase();
        if ((exceptionString.contains('timeout') || 
             exceptionString.contains('network') ||
             exceptionString.contains('connection')) && 
            retryCount < 2) {
          // Wait a bit before retrying
          await Future.delayed(Duration(seconds: 2 + retryCount));
          return _loadData(retryCount: retryCount + 1);
        }
        throw Exception(result.exception.toString());
      }
      
      if (result.data != null) {
        final data = result.data!;
        
        // Parse upcoming launches
        if (data['launchesUpcoming'] != null) {
          _upcomingLaunches = (data['launchesUpcoming'] as List)
              .map((json) => Launch.fromJson(json))
              .toList();
        }
        
        // Parse past launches
        if (data['launchesPast'] != null) {
          _pastLaunches = (data['launchesPast'] as List)
              .map((json) => Launch.fromJson(json))
              .toList();
        }
        
        // Parse launchpads
        if (data['launchpads'] != null) {
          _launchpads = (data['launchpads'] as List)
              .map((json) => LaunchpadModel.fromJson(json))
              .toList();
        }
        
        // Parse landpads
        if (data['landpads'] != null) {
          _landpads = (data['landpads'] as List)
              .map((json) => LandpadModel.fromJson(json))
              .toList();
        }
        
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // Check if it's a timeout error and retry automatically
      final errorString = e.toString().toLowerCase();
      if ((errorString.contains('timeout') || 
           errorString.contains('network') ||
           errorString.contains('connection')) && 
          retryCount < 2) {
        // Wait a bit before retrying
        await Future.delayed(Duration(seconds: 2 + retryCount));
        return _loadData(retryCount: retryCount + 1);
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar - Explorer
              CustomAppBar.launches(),
              
              // Content
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // Tab Bar - Pixel Perfect Design with underline
                    SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedTabIndex = 0),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 3.w),
                                  decoration: BoxDecoration(
                                    border: _selectedTabIndex == 0
                                        ? const Border(
                                            bottom: BorderSide(
                                              color: Color(0xFF3B82F6),
                                              width: 3,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Text(
                                    'Launches',
                                    textAlign: TextAlign.center,
                                    style: _selectedTabIndex == 0
                                        ? AppTypography.getBody(isDark).copyWith(
                                            fontWeight: AppTypography.medium,
                                          )
                                        : AppTypography.getBody(isDark).copyWith(
                                            color: const Color(0xFF9CA3AF),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedTabIndex = 1),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 3.w),
                                  decoration: BoxDecoration(
                                    border: _selectedTabIndex == 1
                                        ? const Border(
                                            bottom: BorderSide(
                                              color: Color(0xFF3B82F6),
                                              width: 3,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Text(
                                    'Launchpad',
                                    textAlign: TextAlign.center,
                                    style: _selectedTabIndex == 1
                                        ? AppTypography.getBody(isDark).copyWith(
                                            fontWeight: AppTypography.medium,
                                          )
                                        : AppTypography.getBody(isDark).copyWith(
                                            color: const Color(0xFF9CA3AF),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedTabIndex = 2),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 3.w),
                                  decoration: BoxDecoration(
                                    border: _selectedTabIndex == 2
                                        ? const Border(
                                            bottom: BorderSide(
                                              color: Color(0xFF3B82F6),
                                              width: 3,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Text(
                                    'Landpad',
                                    textAlign: TextAlign.center,
                                    style: _selectedTabIndex == 2
                                        ? AppTypography.getBody(isDark).copyWith(
                                            fontWeight: AppTypography.medium,
                                          )
                                        : AppTypography.getBody(isDark).copyWith(
                                            color: const Color(0xFF9CA3AF),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tab content
                    if (_isLoading)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Loading SpaceX data...',
                                style: AppTypography.getBody(isDark),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverFillRemaining(
                        child: IndexedStack(
                          index: _selectedTabIndex,
                          children: [
                            _buildLaunchesTab(),
                            _buildLaunchpadsTab(),
                            _buildLandpadsTab(),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  /// Builds the launches tab content with dynamic data
  Widget _buildLaunchesTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allLaunches = [..._upcomingLaunches, ..._pastLaunches];
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Stats Section with dynamic data
          Container(
            margin: EdgeInsets.only(bottom: 4.w),
            child: Row(
              children: [
                Expanded(
                  child: ModernCard(
                    isDark: isDark,
                    margin: EdgeInsets.only(right: 2.w),
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      children: [
                        Text(
                          'UPCOMING',
                          style: AppTypography.getCaption(isDark),
                        ),
                        SizedBox(height: 2.w),
                        Text(
                          '${_upcomingLaunches.length}',
                          style: AppTypography.getHeadline(isDark),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ModernCard(
                    isDark: isDark,
                    margin: EdgeInsets.symmetric(horizontal: 1.w),
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      children: [
                        Text(
                          'PAST',
                          style: AppTypography.getCaption(isDark),
                        ),
                        SizedBox(height: 2.w),
                        Text(
                          '${_pastLaunches.length}',
                          style: AppTypography.getHeadline(isDark),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ModernCard(
                    isDark: isDark,
                    margin: EdgeInsets.only(left: 2.w),
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      children: [
                        Text(
                          'SUCCESS %',
                          style: AppTypography.getCaption(isDark),
                        ),
                        SizedBox(height: 2.w),
                        Text(
                          _calculateSuccessRate().toStringAsFixed(1),
                          style: AppTypography.getHeadline(isDark).copyWith(
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Dynamic launch cards
          ...allLaunches.map((launch) => Padding(
            padding: EdgeInsets.only(bottom: 4.w),
            child: _buildDynamicLaunchCard(launch, isDark),
          )).toList(),
          // End of dynamic launch cards
        ],
      ),
    );
  }

  /// Builds dynamic launch card from GraphQL data
  Widget _buildDynamicLaunchCard(Launch launch, bool isDark) {
    final isUpcoming = launch.upcoming;
    final statusColor = isUpcoming 
        ? const Color(0xFFF59E0B) 
        : (launch.launchSuccess == true ? const Color(0xFF10B981) : const Color(0xFFEF4444));
    final status = isUpcoming ? 'Upcoming' : (launch.launchSuccess == true ? 'Success' : 'Failed');
    
    return ModernCard(
      isDark: isDark,
      margin: EdgeInsets.only(bottom: 4.w),
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status and date row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _formatDate(launch.launchDateUtc),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.w),

          // Mission name and icon
          Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.rocket_launch,
                  color: const Color(0xFF3B82F6),
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      launch.missionName,
                      style: AppTypography.getBody(isDark).copyWith(
                        fontWeight: AppTypography.medium,
                      ),
                    ),
                    Text(
                      'Rocket: ${launch.rocket.rocketName}',
                      style: AppTypography.getCaption(isDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.w),

          // Launch details
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(launch.launchDateUtc),
                      style: AppTypography.getBody(isDark).copyWith(
                        fontWeight: AppTypography.medium,
                      ),
                    ),
                    Text(
                      'Year: ${launch.launchYear}',
                      style: AppTypography.getCaption(isDark),
                    ),
                    if (launch.details != null)
                      Text(
                        launch.details!,
                        style: AppTypography.getCaption(isDark),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Formats date string for display
  String _formatDate(String? dateString) {
    if (dateString == null) return 'TBD';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'TBD';
    }
  }

  /// Calculates success rate from past launches
  double _calculateSuccessRate() {
    if (_pastLaunches.isEmpty) return 0.0;
    
    final successfulLaunches = _pastLaunches.where((launch) => launch.launchSuccess == true).length;
    return (successfulLaunches / _pastLaunches.length) * 100;
  }

  /// Builds launchpads tab content
  Widget _buildLaunchpadsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          ..._launchpads.map((launchpad) => Padding(
            padding: EdgeInsets.only(bottom: 4.w),
            child: _buildDynamicLaunchpadCard(launchpad, isDark),
          )).toList(),
        ],
      ),
    );
  }

  /// Builds landpads tab content
  Widget _buildLandpadsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          ..._landpads.map((landpad) => Padding(
            padding: EdgeInsets.only(bottom: 4.w),
            child: _buildDynamicLandpadCard(landpad, isDark),
          )).toList(),
        ],
      ),
    );
  }

  /// Builds dynamic launchpad card from GraphQL data
  Widget _buildDynamicLaunchpadCard(LaunchpadModel launchpad, bool isDark) {
    final statusColor = launchpad.status == 'active' 
        ? const Color(0xFF10B981) 
        : const Color(0xFFF59E0B);
    final status = launchpad.status == 'active' ? 'Active' : 'Inactive';
    
    return ModernCard(
      isDark: isDark,
      margin: EdgeInsets.only(bottom: 4.w),
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.w),

          // Name and location
          Text(
            launchpad.name,
            style: AppTypography.getBody(isDark).copyWith(
              fontWeight: AppTypography.medium,
            ),
          ),
          if (launchpad.location != null)
            Text(
              '${launchpad.location!.name}, ${launchpad.location!.region}',
              style: AppTypography.getCaption(isDark),
            ),
          SizedBox(height: 2.w),

          // Details
          if (launchpad.details != null)
            Text(
              launchpad.details!,
              style: AppTypography.getCaption(isDark),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  /// Builds dynamic landpad card from GraphQL data
  Widget _buildDynamicLandpadCard(LandpadModel landpad, bool isDark) {
    final statusColor = landpad.status == 'active' 
        ? const Color(0xFF10B981) 
        : const Color(0xFFF59E0B);
    final status = landpad.status == 'active' ? 'Active' : 'Inactive';
    
    return ModernCard(
      isDark: isDark,
      margin: EdgeInsets.only(bottom: 4.w),
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.w),

          // Name and type
          Text(
            landpad.fullName,
            style: AppTypography.getBody(isDark).copyWith(
              fontWeight: AppTypography.medium,
            ),
          ),
          if (landpad.landingType != null)
            Text(
              'Type: ${landpad.landingType}',
              style: AppTypography.getCaption(isDark),
            ),
          if (landpad.location != null)
            Text(
              '${landpad.location!.name}, ${landpad.location!.region}',
              style: AppTypography.getCaption(isDark),
            ),
          SizedBox(height: 2.w),

          // Details
          if (landpad.details != null)
            Text(
              landpad.details!,
              style: AppTypography.getCaption(isDark),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}