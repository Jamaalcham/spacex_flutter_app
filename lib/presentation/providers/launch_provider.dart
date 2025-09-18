import 'package:flutter/material.dart';

import '../../domain/entities/launch_entity.dart';
import '../../domain/repositories/launch_repository.dart';
import '../../data/repositories/launch_repository_impl.dart';
import '../../core/utils/exceptions.dart';

/// Filter options for launches
enum LaunchFilter { all, upcoming, past, successful, failed }

/// Provider for managing launch-related state and operations
/// 
/// This provider handles fetching, caching, and managing SpaceX launch data
/// for the presentation layer. It provides reactive state management for
/// launch screens and widgets.
class LaunchProvider extends ChangeNotifier {
  final LaunchRepository _repository;

  // State variables
  List<LaunchEntity> _launches = [];
  List<LaunchEntity> _filteredLaunches = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  String _searchQuery = '';
  LaunchFilter _currentFilter = LaunchFilter.all;
  
  // Pagination
  int _currentPage = 0;
  final int _pageSize = 10; // Reduced page size for faster initial loading
  bool _hasMoreData = true;
  
  // View mode
  bool _isGridView = false;

  LaunchProvider({LaunchRepository? repository})
      : _repository = repository ?? LaunchRepositoryImpl();

  // Getters
  List<LaunchEntity> get launches => _filteredLaunches;
  List<LaunchEntity> get upcomingLaunches => _launches.where((l) => l.upcoming == true).toList();
  List<LaunchEntity> get pastLaunches => _launches.where((l) => l.upcoming == false).toList();
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  LaunchFilter get currentFilter => _currentFilter;
  bool get hasMoreData => _hasMoreData;
  bool get isGridView => _isGridView;

  /// Fetches launches based on current filter
  Future<void> fetchLaunches() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    _currentPage = 0;
    _hasMoreData = true;
    notifyListeners();

    try {
      List<LaunchEntity> fetchedLaunches;
      
      switch (_currentFilter) {
        case LaunchFilter.upcoming:
          fetchedLaunches = await _repository.getUpcomingLaunches();
          _hasMoreData = false; // Upcoming launches are finite
          break;
        case LaunchFilter.past:
          fetchedLaunches = await _repository.getPastLaunches(limit: _pageSize);
          _hasMoreData = fetchedLaunches.length == _pageSize;
          break;
        case LaunchFilter.successful:
          fetchedLaunches = await _repository.getLaunchesBySuccess(success: true, limit: _pageSize);
          _hasMoreData = fetchedLaunches.length == _pageSize;
          break;
        case LaunchFilter.failed:
          fetchedLaunches = await _repository.getLaunchesBySuccess(success: false, limit: _pageSize);
          _hasMoreData = fetchedLaunches.length == _pageSize;
          break;
        default:
          // For 'all' filter, use optimized pagination
          fetchedLaunches = await _repository.getLaunchesWithPagination(
            limit: _pageSize,
            offset: 0,
          );
          // Check if we have more data by seeing if we got the full page size
          _hasMoreData = fetchedLaunches.length >= _pageSize;
      }
      
      _launches = fetchedLaunches;
      _applyFilters();
    } catch (e) {
      _error = _getErrorMessage(e);
      _launches = [];
      _filteredLaunches = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads more launches for pagination
  Future<void> loadMoreLaunches() async {
    if (_isLoadingMore || !_hasMoreData) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      List<LaunchEntity> moreLaunches;
      
      switch (_currentFilter) {
        case LaunchFilter.upcoming:
          // No more data for upcoming launches
          _hasMoreData = false;
          return;
        case LaunchFilter.past:
          moreLaunches = await _repository.getPastLaunches(limit: _pageSize);
          break;
        case LaunchFilter.successful:
          moreLaunches = await _repository.getLaunchesBySuccess(success: true, limit: _pageSize);
          break;
        case LaunchFilter.failed:
          moreLaunches = await _repository.getLaunchesBySuccess(success: false, limit: _pageSize);
          break;
        default:
          // For 'all' filter, load more with proper offset
          moreLaunches = await _repository.getLaunchesWithPagination(
            limit: _pageSize,
            offset: nextPage * _pageSize,
          );
      }

      if (moreLaunches.isNotEmpty) {
        _launches.addAll(moreLaunches);
        _currentPage = nextPage;
        _hasMoreData = moreLaunches.length >= _pageSize;
        _applyFilters();
      } else {
        _hasMoreData = false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Searches launches by mission name or rocket name
  Future<void> searchLaunches(String query) async {
    _searchQuery = query.trim();
    
    if (_searchQuery.isEmpty) {
      _applyFilters();
      return;
    }

    try {
      final searchResults = await _repository.searchLaunches(
        searchTerm: _searchQuery,
        limit: 50,
      );
      
      _launches = searchResults;
      _applyFilters();
    } catch (e) {
      _error = _getErrorMessage(e);
    }
    
    notifyListeners();
  }

  /// Filters launches by type
  Future<void> filterLaunches(LaunchFilter filter) async {
    if (_currentFilter == filter) return;
    
    _currentFilter = filter;
    await fetchLaunches();
  }

  /// Refreshes launch data
  Future<void> refreshLaunches() async {
    try {
      _error = null;
      final refreshedLaunches = await _repository.refreshLaunches();
      _launches = refreshedLaunches;
      _applyFilters();
    } catch (e) {
      _error = _getErrorMessage(e);
    }
    notifyListeners();
  }

  /// Toggles between list and grid view
  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  /// Applies current search and filter criteria
  void _applyFilters() {
    _filteredLaunches = _launches.where((launch) {
      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesMission = launch.missionName.toLowerCase().contains(query);
        final matchesRocket = launch.rocket?.name.toLowerCase().contains(query) ?? false;
        
        if (!matchesMission && !matchesRocket) {
          return false;
        }
      }
      
      return true;
    }).toList();

    // Sort launches by date (upcoming first, then past in reverse chronological order)
    _filteredLaunches.sort((a, b) {
      if (a.upcoming == true && b.upcoming != true) return -1;
      if (b.upcoming == true && a.upcoming != true) return 1;
      
      if (a.dateUtc == null && b.dateUtc == null) return 0;
      if (a.dateUtc == null) return 1;
      if (b.dateUtc == null) return -1;
      
      if (a.upcoming == true) {
        return a.dateUtc!.compareTo(b.dateUtc!); // Upcoming: earliest first
      } else {
        return b.dateUtc!.compareTo(a.dateUtc!); // Past: latest first
      }
    });
  }

  /// Gets launch statistics
  Map<String, dynamic> getLaunchStats() {
    final stats = <String, dynamic>{
      'totalLaunches': _launches.length,
      'upcomingLaunches': _launches.where((l) => l.upcoming == true).length,
      'pastLaunches': _launches.where((l) => l.upcoming == false).length,
      'successfulLaunches': _launches.where((l) => l.success == true).length,
      'failedLaunches': _launches.where((l) => l.success == false).length,
    };

    final successfulLaunches = _launches.where((l) => l.success != null).toList();
    if (successfulLaunches.isNotEmpty) {
      final successCount = successfulLaunches.where((l) => l.success == true).length;
      stats['successRate'] = (successCount / successfulLaunches.length) * 100;
    }

    return stats;
  }

  /// Gets total launch count
  int get launchCount => _filteredLaunches.length;

  /// Gets upcoming launch count
  int get upcomingLaunchCount => _filteredLaunches.where((l) => l.upcoming == true).length;

  /// Gets past launch count
  int get pastLaunchCount => _filteredLaunches.where((l) => l.upcoming == false).length;

  /// Gets successful launch count
  int get successfulLaunchCount => _filteredLaunches.where((l) => l.success == true).length;

  /// Gets failed launch count
  int get failedLaunchCount => _filteredLaunches.where((l) => l.success == false).length;

  /// Checks if launch list is empty
  bool get isEmpty => _filteredLaunches.isEmpty;

  /// Gets next upcoming launch
  LaunchEntity? get nextUpcomingLaunch {
    final upcoming = _filteredLaunches
        .where((l) => l.upcoming == true && l.dateUtc != null)
        .toList();
    
    if (upcoming.isEmpty) return null;
    
    upcoming.sort((a, b) => a.dateUtc!.compareTo(b.dateUtc!));
    return upcoming.first;
  }

  /// Clears current error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Converts exception to user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is NetworkException) {
      return 'No internet connection. Please check your network and try again.';
    } else if (error is ServerException) {
      return 'Server error occurred. Please try again later.';
    } else if (error is NotFoundException) {
      return 'Launch data not found. Please try refreshing.';
    } else if (error is CacheException) {
      return 'Cache error occurred. Please clear app data and try again.';
    } else if (error is DataException) {
      return 'Invalid data received. Please try again.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}
