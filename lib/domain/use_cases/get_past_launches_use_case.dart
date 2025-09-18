import '../entities/launch_entity.dart';
import '../repositories/launch_repository.dart';
import 'base_use_case.dart';

/// Use case for getting past launches
/// 
/// This use case handles the business logic for fetching past launches
/// with proper filtering and sorting.
class GetPastLaunchesUseCase extends BaseUseCaseNoParams<List<LaunchEntity>> {
  final LaunchRepository repository;

  GetPastLaunchesUseCase(this.repository);

  @override
  Future<List<LaunchEntity>> execute() async {
    try {
      final launches = await repository.getPastLaunches();
      
      // Business logic: Filter and sort past launches
      final now = DateTime.now();
      final pastLaunches = launches.where((launch) {
        // Filter by past status and past date
        return launch.upcoming == false && 
               (launch.dateUtc != null && launch.dateUtc!.isBefore(now));
      }).toList();
      
      // Sort by launch date (most recent first for past launches)
      pastLaunches.sort((a, b) {
        if (a.dateUtc == null && b.dateUtc == null) return 0;
        if (a.dateUtc == null) return 1;
        if (b.dateUtc == null) return -1;
        return b.dateUtc!.compareTo(a.dateUtc!);
      });
      
      return pastLaunches;
    } catch (e) {
      throw Exception('Failed to fetch past launches: ${e.toString()}');
    }
  }
}
