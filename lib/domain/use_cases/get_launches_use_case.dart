import '../entities/launch_entity.dart';
import '../repositories/launch_repository.dart';
import 'base_use_case.dart';

/// Use case for getting all launches
/// 
/// This use case handles the business logic for fetching all launches
/// from the repository with proper sorting and validation.
class GetLaunchesUseCase extends BaseUseCaseNoParams<List<LaunchEntity>> {
  final LaunchRepository repository;

  GetLaunchesUseCase(this.repository);

  @override
  Future<List<LaunchEntity>> execute() async {
    try {
      final launches = await repository.getLaunchesWithPagination(limit: 100);
      
      // Business logic: Sort launches by date (most recent first)
      launches.sort((a, b) {
        if (a.dateUtc == null && b.dateUtc == null) return 0;
        if (a.dateUtc == null) return 1;
        if (b.dateUtc == null) return -1;
        return b.dateUtc!.compareTo(a.dateUtc!);
      });
      
      return launches;
    } catch (e) {
      throw Exception('Failed to fetch launches: ${e.toString()}');
    }
  }
}
