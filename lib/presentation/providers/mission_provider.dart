import 'package:flutter/material.dart';

import '../../domain/entities/mission_entity.dart';
import '../../domain/repositories/mission_repository.dart';
import '../../data/repositories/mission_repository_impl.dart';
import '../../core/utils/exceptions.dart';

/// Provider for managing mission-related state and operations
/// 
/// This provider handles all mission data operations including fetching,
/// searching, filtering, and pagination. It provides reactive state
/// management for mission-related UI components.
class MissionProvider extends ChangeNotifier {
  final MissionRepository _repository;

  // State variables
  List<MissionEntity> _missions = [];
  List<MissionEntity> _filteredMissions = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  String _searchQuery = '';
  List<String> _selectedManufacturers = [];
  
  // Pagination
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMoreData = true;
  
  // View mode
  bool _isGridView = false;

  MissionProvider({MissionRepository? repository})
      : _repository = repository ?? MissionRepositoryImpl();

  // Getters
  List<MissionEntity> get missions => _filteredMissions.isEmpty && _searchQuery.isEmpty 
      ? _missions 
      : _filteredMissions;
  
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  List<String> get selectedManufacturers => _selectedManufacturers;
  bool get hasMoreData => _hasMoreData;
  bool get isGridView => _isGridView;
  bool get isEmpty => missions.isEmpty && !_isLoading;
  int get missionCount => missions.length;

  /// Fetches initial missions data
  Future<void> fetchMissions() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    _currentPage = 0;
    _hasMoreData = true;
    notifyListeners();

    try {
      final fetchedMissions = await _repository.getMissionsWithPagination(
        limit: _pageSize,
        offset: 0,
      );
      
      _missions = fetchedMissions;
      _hasMoreData = fetchedMissions.length == _pageSize;
      _applyFilters();
    } catch (e) {
      _error = _getErrorMessage(e);
      _missions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads more missions for pagination
  Future<void> loadMoreMissions() async {
    if (_isLoadingMore || !_hasMoreData || _searchQuery.isNotEmpty) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final moreMissions = await _repository.getMissionsWithPagination(
        limit: _pageSize,
        offset: nextPage * _pageSize,
      );

      if (moreMissions.isNotEmpty) {
        _missions.addAll(moreMissions);
        _currentPage = nextPage;
        _hasMoreData = moreMissions.length == _pageSize;
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

  /// Searches missions by name or description
  Future<void> searchMissions(String query) async {
    _searchQuery = query.trim();
    
    if (_searchQuery.isEmpty) {
      _applyFilters();
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final searchResults = await _repository.searchMissions(_searchQuery);
      _filteredMissions = searchResults;
    } catch (e) {
      _error = _getErrorMessage(e);
      _filteredMissions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filters missions by manufacturers
  void filterByManufacturers(List<String> manufacturers) {
    _selectedManufacturers = manufacturers;
    _applyFilters();
    notifyListeners();
  }

  /// Applies current filters to missions list
  void _applyFilters() {
    if (_searchQuery.isNotEmpty) {
      // Search results are already filtered
      return;
    }

    if (_selectedManufacturers.isEmpty) {
      _filteredMissions = [];
      return;
    }

    _filteredMissions = _missions.where((mission) {
      return mission.manufacturers.any((manufacturer) =>
          _selectedManufacturers.contains(manufacturer));
    }).toList();
  }

  /// Clears all filters and search
  void clearFilters() {
    _searchQuery = '';
    _selectedManufacturers = [];
    _filteredMissions = [];
    notifyListeners();
  }

  /// Refreshes missions data
  Future<void> refreshMissions() async {
    _currentPage = 0;
    _hasMoreData = true;
    await fetchMissions();
  }

  /// Toggles between grid and list view
  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  /// Gets a specific mission by ID
  Future<MissionEntity?> getMissionById(String id) async {
    try {
      // First check if mission is already in memory
      final existingMission = _missions.firstWhere(
        (mission) => mission.id == id,
        orElse: () => throw StateError('Mission not found'),
      );
      return existingMission;
    } catch (e) {
      // If not in memory, fetch from repository
      try {
        return await _repository.getMissionById(id);
      } catch (e) {
        return null;
      }
    }
  }

  /// Gets all unique manufacturers from current missions
  List<String> getAllManufacturers() {
    final manufacturers = <String>{};
    for (final mission in _missions) {
      manufacturers.addAll(mission.manufacturers);
    }
    return manufacturers.toList()..sort();
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
      return 'Server error. Please try again later.';
    } else if (error is NotFoundException) {
      return 'No missions found.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  @override
  void dispose() {
    // Clean up resources
    _missions.clear();
    _filteredMissions.clear();
    super.dispose();
  }
}
