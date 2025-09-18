import '../entities/launchpad_entity.dart';
import '../repositories/launchpad_repository.dart';
import 'base_use_case.dart';

/// Use case for getting all launchpads
/// 
/// This use case handles the business logic for fetching all launchpads
/// from the repository with proper sorting and validation.
class GetLaunchpadsUseCase extends BaseUseCaseNoParams<List<LaunchpadEntity>> {
  final LaunchpadRepository repository;

  GetLaunchpadsUseCase(this.repository);

  @override
  Future<List<LaunchpadEntity>> execute() async {
    try {
      final launchpads = await repository.getLaunchpads(limit: 100);
      
      // Business logic: Sort launchpads by name for consistent display
      launchpads.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      
      return launchpads;
    } catch (e) {
      throw Exception('Failed to fetch launchpads: ${e.toString()}');
    }
  }
}
