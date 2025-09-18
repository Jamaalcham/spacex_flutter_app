import 'package:flutter/material.dart';

import '../../domain/entities/landpad_entity.dart';
import '../../domain/repositories/landpad_repository.dart';
import '../../data/repositories/landpad_repository_impl.dart';
import '../../core/utils/exceptions.dart';

/// Provider for managing landpad-related state and operations
class LandpadProvider extends ChangeNotifier {
  final LandpadRepository _repository;

  // State variables
  List<LandpadEntity> _landpads = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  
  // Pagination
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMoreData = true;

  LandpadProvider({LandpadRepository? repository})
      : _repository = repository ?? LandpadRepositoryImpl();

  // Getters
  List<LandpadEntity> get landpads => _landpads;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMoreData => _hasMoreData;

  /// Fetches landpads
  Future<void> fetchLandpads() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    _currentPage = 0;
    _hasMoreData = true;
    notifyListeners();

    try {
      final fetchedLandpads = await _repository.getLandpads(
        limit: _pageSize,
        offset: 0,
      );
      
      _landpads = fetchedLandpads;
      _hasMoreData = fetchedLandpads.length == _pageSize;
    } catch (e) {
      _error = _getErrorMessage(e);
      _landpads = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads more landpads for pagination
  Future<void> loadMoreLandpads() async {
    if (_isLoadingMore || !_hasMoreData) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final moreLandpads = await _repository.getLandpads(
        limit: _pageSize,
        offset: nextPage * _pageSize,
      );

      if (moreLandpads.isNotEmpty) {
        _landpads.addAll(moreLandpads);
        _currentPage = nextPage;
        _hasMoreData = moreLandpads.length == _pageSize;
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

  /// Refreshes landpad data
  Future<void> refreshLandpads() async {
    try {
      _error = null;
      final refreshedLandpads = await _repository.refreshLandpads();
      _landpads = refreshedLandpads;
    } catch (e) {
      _error = _getErrorMessage(e);
    }
    notifyListeners();
  }

  /// Gets landpad statistics
  Map<String, dynamic> getLandpadStats() {
    final activeLandpads = _landpads.where((l) => l.status == 'active').length;
    final totalLandings = _landpads.fold<int>(0, (sum, l) => sum + (l.successfulLandings ?? 0));

    return {
      'totalLandpads': _landpads.length,
      'activeLandpads': activeLandpads,
      'inactiveLandpads': _landpads.length - activeLandpads,
      'totalLandings': totalLandings,
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
      return 'Landpad data not found. Please try refreshing.';
    } else if (error is CacheException) {
      return 'Cache error occurred. Please clear app data and try again.';
    } else if (error is DataException) {
      return 'Invalid data received. Please try again.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}
