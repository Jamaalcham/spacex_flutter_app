import '../entities/landpad_entity.dart';

// Repository interface for landpad operations
abstract class LandpadRepository {
  // Fetches landpads with pagination
  Future<List<LandpadEntity>> getLandpads({
    int limit = 20,
    int offset = 0,
  });

  // Refreshes landpad data
  Future<List<LandpadEntity>> refreshLandpads();
}
