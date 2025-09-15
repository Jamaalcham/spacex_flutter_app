import '../entities/capsule_entity.dart';

/// Abstract repository interface for capsule data operations
/// 
/// This interface defines the contract for capsule data access,
/// allowing for different implementations (REST API, GraphQL, local storage, etc.)
/// while keeping the domain layer independent of data sources.
abstract class CapsuleRepository {
  /// Fetches all capsules with pagination support
  /// 
  /// [limit] - Maximum number of capsules to return
  /// [offset] - Number of capsules to skip for pagination
  /// 
  /// Returns a list of [CapsuleEntity] objects
  /// Throws [NetworkException] if network request fails
  /// Throws [ServerException] if server returns an error
  /// Throws [NotFoundException] if no capsules are found
  Future<List<CapsuleEntity>> getCapsulesWithPagination({
    int limit = 20,
    int offset = 0,
  });

  /// Searches for capsules by serial number or type
  /// 
  /// [query] - Search term to match against capsule serial or type
  /// 
  /// Returns a list of matching [CapsuleEntity] objects
  /// Throws [NetworkException] if network request fails
  /// Throws [ServerException] if server returns an error
  Future<List<CapsuleEntity>> searchCapsules(String query);

  /// Fetches a specific capsule by its unique identifier
  /// 
  /// [id] - Unique identifier of the capsule
  /// 
  /// Returns a [CapsuleEntity] object if found
  /// Throws [NetworkException] if network request fails
  /// Throws [ServerException] if server returns an error
  /// Throws [NotFoundException] if capsule is not found
  Future<CapsuleEntity> getCapsuleById(String id);

  /// Fetches capsules filtered by status
  /// 
  /// [status] - Status to filter by (active, retired, destroyed, unknown)
  /// [limit] - Maximum number of capsules to return
  /// [offset] - Number of capsules to skip for pagination
  /// 
  /// Returns a list of [CapsuleEntity] objects with the specified status
  /// Throws [NetworkException] if network request fails
  /// Throws [ServerException] if server returns an error
  Future<List<CapsuleEntity>> getCapsulesByStatus({
    required String status,
    int limit = 20,
    int offset = 0,
  });

  /// Fetches capsules that have been reused
  /// 
  /// [limit] - Maximum number of capsules to return
  /// [offset] - Number of capsules to skip for pagination
  /// 
  /// Returns a list of [CapsuleEntity] objects that have been reused
  /// Throws [NetworkException] if network request fails
  /// Throws [ServerException] if server returns an error
  Future<List<CapsuleEntity>> getReusedCapsules({
    int limit = 20,
    int offset = 0,
  });
}
