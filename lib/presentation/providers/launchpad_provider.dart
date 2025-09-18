import 'package:flutter/material.dart';

import '../../domain/entities/launchpad_entity.dart';
import '../../domain/repositories/launchpad_repository.dart';
import '../../data/repositories/launchpad_repository_impl.dart';
import '../../core/utils/exceptions.dart';

/// Provider for managing launchpad-related state and operations
class LaunchpadProvider extends ChangeNotifier {
  final LaunchpadRepository _repository;

  // State variables
  List<LaunchpadEntity> _launchpads = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  
  // Pagination
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMoreData = true;

  LaunchpadProvider({LaunchpadRepository? repository})
      : _repository = repository ?? LaunchpadRepositoryImpl();

  // Getters
  List<LaunchpadEntity> get launchpads => _launchpads;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMoreData => _hasMoreData;

  /// Fetches launchpads
  Future<void> fetchLaunchpads() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    _currentPage = 0;
    _hasMoreData = true;
    notifyListeners();

    try {
      final fetchedLaunchpads = await _repository.getLaunchpads(
        limit: _pageSize,
        offset: 0,
      );
      
      _launchpads = fetchedLaunchpads;
      _hasMoreData = fetchedLaunchpads.length == _pageSize;
    } catch (e) {
      _error = _getErrorMessage(e);
      _launchpads = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads more launchpads for pagination
  Future<void> loadMoreLaunchpads() async {
    if (_isLoadingMore || !_hasMoreData) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final moreLaunchpads = await _repository.getLaunchpads(
        limit: _pageSize,
        offset: nextPage * _pageSize,
      );

      if (moreLaunchpads.isNotEmpty) {
        _launchpads.addAll(moreLaunchpads);
        _currentPage = nextPage;
        _hasMoreData = moreLaunchpads.length == _pageSize;
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

  /// Refreshes launchpad data
  Future<void> refreshLaunchpads() async {
    try {
      _error = null;
      final refreshedLaunchpads = await _repository.refreshLaunchpads();
      _launchpads = refreshedLaunchpads;
    } catch (e) {
      _error = _getErrorMessage(e);
    }
    notifyListeners();
  }

  /// Gets launchpad statistics
  Map<String, dynamic> getLaunchpadStats() {
    final activeLaunchpads = _launchpads.where((l) => l.status == 'active').length;
    final totalLaunches = _launchpads.fold<int>(0, (sum, l) => sum + (l.successfulLaunches ?? 0));

    return {
      'totalLaunchpads': _launchpads.length,
      'activeLaunchpads': activeLaunchpads,
      'inactiveLaunchpads': _launchpads.length - activeLaunchpads,
      'totalLaunches': totalLaunches,
    };
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
      return 'Launchpad data not found. Please try refreshing.';
    } else if (error is CacheException) {
      return 'Cache error occurred. Please clear app data and try again.';
    } else if (error is DataException) {
      return 'Invalid data received. Please try again.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}
