import '../entities/launch_entity.dart';

/// Abstract repository interface for launch data operations
/// 
/// This interface defines the contract for launch data access,
/// allowing for different implementations while maintaining
/// consistent business logic in the domain layer.
abstract class LaunchRepository {
  /// Fetches all launches with pagination support
  /// 
  /// [limit] Maximum number of launches to fetch
  /// [offset] Number of launches to skip for pagination
  /// 
  /// Returns a list of launches or throws an exception if the operation fails
  Future<List<LaunchEntity>> getLaunchesWithPagination({
    int limit = 20,
    int offset = 0,
  });

  /// Fetches upcoming launches
  /// 
  /// Returns launches that are scheduled for the future
  Future<List<LaunchEntity>> getUpcomingLaunches();

  /// Fetches past launches
  /// 
  /// [limit] Maximum number of past launches to fetch
  /// 
  /// Returns launches that have already occurred
  Future<List<LaunchEntity>> getPastLaunches({int limit = 50});

  /// Fetches launches by mission name or rocket name
  /// 
  /// [searchTerm] The term to search for in mission and rocket names
  /// [limit] Maximum number of results to return
  /// [offset] Number of results to skip for pagination
  /// 
  /// Returns matching launches
  Future<List<LaunchEntity>> searchLaunches({
    required String searchTerm,
    int limit = 20,
    int offset = 0,
  });

  /// Fetches launches filtered by success status
  /// 
  /// [success] Filter by launch success (true/false/null for all)
  /// [limit] Maximum number of results to return
  /// 
  /// Returns filtered launches
  Future<List<LaunchEntity>> getLaunchesBySuccess({
    bool? success,
    int limit = 50,
  });

  /// Fetches launches by date range
  /// 
  /// [startDate] Start of date range (ISO string)
  /// [endDate] End of date range (ISO string)
  /// 
  /// Returns launches within the specified date range
  Future<List<LaunchEntity>> getLaunchesByDateRange({
    required String startDate,
    required String endDate,
  });

  /// Fetches a specific launch by flight number
  /// 
  /// [flightNumber] The unique flight number of the launch
  /// 
  /// Returns the launch entity or throws an exception if not found
  Future<LaunchEntity> getLaunchByFlightNumber(int flightNumber);

  /// Refreshes the launch data from the remote source
  /// 
  /// Forces a fresh fetch from the API, bypassing any cache
  Future<List<LaunchEntity>> refreshLaunches();
}
