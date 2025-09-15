import 'package:flutter/material.dart';

import '../../domain/entities/capsule_entity.dart';
import '../../domain/repositories/capsule_repository.dart';
import '../../data/repositories/capsule_repository_impl.dart';
import '../../core/utils/exceptions.dart';

/// Provider for managing capsule-related state and operations
/// 
/// This provider handles all capsule data operations including fetching,
/// searching, filtering, and pagination. It provides reactive state
/// management for capsule-related UI components.
class CapsuleProvider extends ChangeNotifier {
  final CapsuleRepository _repository;

  // State variables
  List<CapsuleEntity> _capsules = [];
  List<CapsuleEntity> _filteredCapsules = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  String _searchQuery = '';
  List<String> _selectedStatuses = [];
  
  // Pagination
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMoreData = true;
  
  // View mode
  bool _isGridView = false;

  CapsuleProvider({CapsuleRepository? repository})
      : _repository = repository ?? CapsuleRepositoryImpl();

  // Getters
  List<CapsuleEntity> get capsules => _filteredCapsules.isEmpty && _searchQuery.isEmpty 
      ? _capsules 
      : _filteredCapsules;
  
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  List<String> get selectedStatuses => _selectedStatuses;
  bool get hasMoreData => _hasMoreData;
  bool get isGridView => _isGridView;
  bool get isEmpty => capsules.isEmpty && !_isLoading;
  int get capsuleCount => capsules.length;

  /// Fetches initial capsules data
  Future<void> fetchCapsules() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    _currentPage = 0;
    _hasMoreData = true;
    notifyListeners();

    try {
      final fetchedCapsules = await _repository.getCapsulesWithPagination(
        limit: _pageSize,
        offset: 0,
      );
      
      _capsules = fetchedCapsules;
      _hasMoreData = fetchedCapsules.length == _pageSize;
      _applyFilters();
    } catch (e) {
      _error = _getErrorMessage(e);
      _capsules = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads more capsules for pagination
  Future<void> loadMoreCapsules() async {
    if (_isLoadingMore || !_hasMoreData || _searchQuery.isNotEmpty) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final moreCapsules = await _repository.getCapsulesWithPagination(
        limit: _pageSize,
        offset: nextPage * _pageSize,
      );

      if (moreCapsules.isNotEmpty) {
        _capsules.addAll(moreCapsules);
        _currentPage = nextPage;
        _hasMoreData = moreCapsules.length == _pageSize;
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

  /// Searches capsules by serial or type
  Future<void> searchCapsules(String query) async {
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
      final searchResults = await _repository.searchCapsules(_searchQuery);
      _filteredCapsules = searchResults;
    } catch (e) {
      _error = _getErrorMessage(e);
      _filteredCapsules = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filters capsules by status
  void filterByStatus(List<String> statuses) {
    _selectedStatuses = statuses;
    _applyFilters();
    notifyListeners();
  }

  /// Applies current filters to capsules list
  void _applyFilters() {
    if (_searchQuery.isNotEmpty) {
      // Search results are already filtered
      return;
    }

    if (_selectedStatuses.isEmpty) {
      _filteredCapsules = [];
      return;
    }

    _filteredCapsules = _capsules.where((capsule) {
      return _selectedStatuses.contains(capsule.status?.toLowerCase());
    }).toList();
  }

  /// Clears all filters and search
  void clearFilters() {
    _searchQuery = '';
    _selectedStatuses = [];
    _filteredCapsules = [];
    notifyListeners();
  }

  /// Refreshes capsules data
  Future<void> refreshCapsules() async {
    _currentPage = 0;
    _hasMoreData = true;
    await fetchCapsules();
  }

  /// Toggles between grid and list view
  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  /// Gets a specific capsule by ID
  Future<CapsuleEntity?> getCapsuleById(String id) async {
    try {
      // First check if capsule is already in memory
      final existingCapsule = _capsules.firstWhere(
        (capsule) => capsule.id == id,
        orElse: () => throw StateError('Capsule not found'),
      );
      return existingCapsule;
    } catch (e) {
      // If not in memory, fetch from repository
      try {
        return await _repository.getCapsuleById(id);
      } catch (e) {
        return null;
      }
    }
  }

  /// Gets all unique statuses from current capsules
  List<String> getAllStatuses() {
    final statuses = <String>{};
    for (final capsule in _capsules) {
      if (capsule.status != null) {
        statuses.add(capsule.status!);
      }
    }
    return statuses.toList()..sort();
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
      return 'No capsules found.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  @override
  void dispose() {
    // Clean up resources
    _capsules.clear();
    _filteredCapsules.clear();
    super.dispose();
  }
}
