import 'package:flutter/material.dart';

import '../../domain/entities/rocket_entity.dart';
import '../../domain/repositories/rocket_repository.dart';
import '../../data/repositories/rocket_repository_impl.dart';
import '../../core/network/network_exceptions.dart';
import '../../domain/use_cases/get_rockets_use_case.dart';
import '../../domain/use_cases/get_rocket_by_id_use_case.dart';
import '../../domain/use_cases/search_rockets_use_case.dart';

/// Provider for managing rocket-related state and operations
/// 
/// This provider handles all rocket data operations including fetching,
/// searching, filtering, and provides reactive state management
/// for rocket-related UI components.
class RocketProvider extends ChangeNotifier {
  final RocketRepository _repository;
  
  // Use cases
  late final GetRocketsUseCase _getRocketsUseCase;
  late final GetRocketByIdUseCase _getRocketByIdUseCase;
  late final SearchRocketsUseCase _searchRocketsUseCase;

  // State variables
  List<RocketEntity> _rockets = [];
  List<RocketEntity> _filteredRockets = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  RocketFilter _currentFilter = RocketFilter.all;
  
  // View mode
  bool _isGridView = true;

  RocketProvider({RocketRepository? repository})
      : _repository = repository ?? RocketRepositoryImpl() {
    // Initialize use cases
    _getRocketsUseCase = GetRocketsUseCase(_repository);
    _getRocketByIdUseCase = GetRocketByIdUseCase(_repository);
    _searchRocketsUseCase = SearchRocketsUseCase(_repository);
  }

  // Getters
  List<RocketEntity> get rockets => _filteredRockets.isEmpty && _searchQuery.isEmpty && _currentFilter == RocketFilter.all
      ? _rockets 
      : _filteredRockets;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  RocketFilter get currentFilter => _currentFilter;
  bool get isGridView => _isGridView;
  bool get isEmpty => rockets.isEmpty && !_isLoading;

  /// Fetches all rockets data using Clean Architecture use case
  Future<void> fetchRockets() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetchedRockets = await _getRocketsUseCase.execute();
      _rockets = fetchedRockets;
      _applyFilters();
    } catch (e) {
      _error = _getErrorMessage(e);
      _rockets = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Searches rockets by name or type using Clean Architecture use case
  Future<void> searchRockets(String query) async {
    _searchQuery = query.trim();
    
    if (_searchQuery.isEmpty) {
      _filteredRockets = [];
      _applyFilters();
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final searchResults = await _searchRocketsUseCase.execute(
        SearchRocketsParams(searchTerm: _searchQuery),
      );
      _filteredRockets = searchResults;
    } catch (e) {
      _error = _getErrorMessage(e);
      _filteredRockets = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filters rockets by status
  void filterRockets(RocketFilter filter) {
    _currentFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  /// Applies current filters to rockets list
  void _applyFilters() {
    if (_searchQuery.isNotEmpty) {
      // Search results are already filtered
      return;
    }

    switch (_currentFilter) {
      case RocketFilter.all:
        _filteredRockets = [];
        break;
      case RocketFilter.active:
        _filteredRockets = _rockets.where((rocket) => rocket.active).toList();
        break;
      case RocketFilter.retired:
        _filteredRockets = _rockets.where((rocket) => !rocket.active).toList();
        break;
    }
  }

  /// Clears all filters and search
  void clearFilters() {
    _searchQuery = '';
    _currentFilter = RocketFilter.all;
    _filteredRockets = [];
    notifyListeners();
  }

  /// Refreshes rockets data
  Future<void> refreshRockets() async {
    await fetchRockets();
  }

  /// Toggles between grid and list view
  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  /// Gets a specific rocket by ID using Clean Architecture use case
  Future<RocketEntity?> getRocketById(String id) async {
    try {
      // First check if rocket is already in memory
      final existingRocket = _rockets.firstWhere(
        (rocket) => rocket.id == id,
        orElse: () => throw StateError('Rocket not found'),
      );
      return existingRocket;
    } catch (e) {
      // If not in memory, fetch using use case
      try {
        return await _getRocketByIdUseCase.execute(
          GetRocketByIdParams(id: id),
        );
      } catch (e) {
        return null;
      }
    }
  }

  /// Gets rockets with images for gallery view
  List<RocketEntity> getRocketsWithImages() {
    // Since our current schema doesn't include images, return empty list
    return [];
  }

  /// Gets statistics about rockets
  Map<String, dynamic> getRocketStats() {
    final Map<String, dynamic> stats = {
      'totalRockets': _rockets.length,
      'activeRockets': _rockets.where((r) => r.active).length,
      'retiredRockets': _rockets.where((r) => !r.active).length,
      'averageSuccessRate': _rockets.isNotEmpty 
          ? _rockets.map((r) => r.successRatePct ?? 0).reduce((a, b) => a + b) / _rockets.length
          : 0,
    };

    final costs = _rockets
        .where((r) => r.costPerLaunch != null)
        .map((r) => r.costPerLaunch!)
        .toList();
    
    if (costs.isNotEmpty) {
      stats['averageCost'] = costs.reduce((a, b) => a + b) / costs.length;
      stats['lowestCost'] = costs.reduce((a, b) => a < b ? a : b);
      stats['highestCost'] = costs.reduce((a, b) => a > b ? a : b);
    }
    
    return stats;
  }

  /// Gets total rocket count
  int get rocketCount => rockets.length;

  /// Gets active rocket count
  int get activeRocketCount => rockets.where((r) => r.active).length;

  /// Gets retired rocket count
  int get retiredRocketCount => rockets.where((r) => !r.active).length;



  /// Clears current error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Converts exception to user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is NetworkException) {
      return error.message;
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  @override
  void dispose() {
    // Clean up resources
    _rockets.clear();
    _filteredRockets.clear();
    super.dispose();
  }
}

/// Enum for rocket filtering options
enum RocketFilter {
  all,
  active,
  retired,
}
