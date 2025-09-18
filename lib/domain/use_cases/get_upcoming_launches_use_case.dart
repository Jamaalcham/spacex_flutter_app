import '../entities/launch_entity.dart';
import '../repositories/launch_repository.dart';
import 'base_use_case.dart';

/// Use case for getting upcoming launches
/// 
/// This use case handles the business logic for fetching upcoming launches
/// with proper filtering and sorting.
class GetUpcomingLaunchesUseCase extends BaseUseCaseNoParams<List<LaunchEntity>> {
  final LaunchRepository repository;

  GetUpcomingLaunchesUseCase(this.repository);

  @override
  Future<List<LaunchEntity>> execute() async {
    try {
      final launches = await repository.getUpcomingLaunches();
      
      // Business logic: Filter and sort upcoming launches
      final now = DateTime.now();
      final upcomingLaunches = launches.where((launch) {
        // Filter by upcoming status and future date
        return launch.upcoming == true || 
               (launch.dateUtc != null && launch.dateUtc!.isAfter(now));
      }).toList();
      
      // Sort by launch date (earliest first for upcoming)
      upcomingLaunches.sort((a, b) {
        if (a.dateUtc == null && b.dateUtc == null) return 0;
        if (a.dateUtc == null) return 1;
        if (b.dateUtc == null) return -1;
        return a.dateUtc!.compareTo(b.dateUtc!);
      });
      
      return upcomingLaunches;
    } catch (e) {
      throw Exception('Failed to fetch upcoming launches: ${e.toString()}');
    }
  }
}
