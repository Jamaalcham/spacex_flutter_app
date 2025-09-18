import '../entities/rocket_entity.dart';

/// Abstract repository interface for rocket data operations
abstract class RocketRepository {
  /// Fetches all available rockets
  /// 
  /// Returns a list of rockets or throws an exception if the operation fails
  Future<List<RocketEntity>> getAllRockets();

  /// Fetches a specific rocket by its unique identifier
  /// 
  /// [id] The unique identifier of the rocket to retrieve
  /// 
  /// Returns the rocket entity or throws an exception if not found
  Future<RocketEntity> getRocketById(String id);

  /// Fetches only active rockets
  /// 
  /// Returns a list of currently operational rockets
  Future<List<RocketEntity>> getActiveRockets();

  /// Searches for rockets based on a search term
  /// 
  /// [searchTerm] The term to search for in rocket names and types
  /// 
  /// Returns a list of matching rockets
  Future<List<RocketEntity>> searchRockets(String searchTerm);

  /// Fetches rockets filtered by company
  /// 
  /// [company] The company name to filter by
  /// 
  /// Returns rockets from the specified company
  Future<List<RocketEntity>> getRocketsByCompany(String company);

  /// Fetches rockets that have images available
  /// 
  /// Returns rockets with Flickr images for gallery display
  Future<List<RocketEntity>> getRocketsWithImages();

  /// Refreshes the rocket data from the remote source
  /// 
  /// Forces a fresh fetch from the API, bypassing any cache
  Future<List<RocketEntity>> refreshRockets();
}
