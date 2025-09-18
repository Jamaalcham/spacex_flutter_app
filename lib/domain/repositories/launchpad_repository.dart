import '../entities/launchpad_entity.dart';

/// Repository interface for launchpad operations
abstract class LaunchpadRepository {
  /// Fetches launchpads with pagination
  Future<List<LaunchpadEntity>> getLaunchpads({
    int limit = 20,
    int offset = 0,
  });

  /// Refreshes launchpad data
  Future<List<LaunchpadEntity>> refreshLaunchpads();
}
