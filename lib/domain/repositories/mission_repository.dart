import '../entities/mission_entity.dart';

/// Abstract repository interface for mission data operations
/// 
/// This interface defines the contract for mission data access,
/// allowing for different implementations (GraphQL, REST, local cache, etc.)
/// while maintaining consistent business logic in the domain layer.
abstract class MissionRepository {
  /// Fetches all available missions
  /// 
  /// Returns a list of missions or throws an exception if the operation fails
  /// 
  /// Throws:
  /// - [NetworkException] when network connectivity issues occur
  /// - [ServerException] when the server returns an error
  /// - [CacheException] when local cache operations fail
  Future<List<MissionEntity>> getAllMissions();

  /// Fetches a specific mission by its unique identifier
  /// 
  /// [id] The unique identifier of the mission to retrieve
  /// 
  /// Returns the mission entity or throws an exception if not found
  /// 
  /// Throws:
  /// - [NetworkException] when network connectivity issues occur
  /// - [ServerException] when the server returns an error
  /// - [NotFoundException] when the mission with given ID doesn't exist
  Future<MissionEntity> getMissionById(String id);

  /// Searches for missions based on a search term
  /// 
  /// [searchTerm] The term to search for in mission names and descriptions
  /// 
  /// Returns a list of matching missions
  Future<List<MissionEntity>> searchMissions(String searchTerm);

  /// Fetches missions with pagination support
  /// 
  /// [limit] Maximum number of missions to return (default: 20)
  /// [offset] Number of missions to skip for pagination (default: 0)
  /// 
  /// Returns a paginated list of missions
  Future<List<MissionEntity>> getMissionsWithPagination({
    int limit = 20,
    int offset = 0,
  });

  /// Fetches missions filtered by manufacturers
  /// 
  /// [manufacturers] List of manufacturer names to filter by
  /// 
  /// Returns missions from the specified manufacturers
  Future<List<MissionEntity>> getMissionsByManufacturers(
    List<String> manufacturers,
  );

  /// Refreshes the mission data from the remote source
  /// 
  /// Forces a fresh fetch from the API, bypassing any cache
  /// 
  /// Returns updated list of missions
  Future<List<MissionEntity>> refreshMissions();
}
