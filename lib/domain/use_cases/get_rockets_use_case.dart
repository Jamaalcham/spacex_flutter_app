import '../entities/rocket_entity.dart';
import '../repositories/rocket_repository.dart';
import 'base_use_case.dart';

/// Use case for getting all rockets
/// 
/// This use case handles the business logic for fetching all rockets
/// from the repository with proper error handling and validation.
class GetRocketsUseCase extends BaseUseCaseNoParams<List<RocketEntity>> {
  final RocketRepository repository;

  GetRocketsUseCase(this.repository);

  @override
  Future<List<RocketEntity>> execute() async {
    try {
      final rockets = await repository.getAllRockets();
      
      // Business logic: Sort rockets by name for consistent display
      rockets.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      
      return rockets;
    } catch (e) {
      // Re-throw with additional context if needed
      throw Exception('Failed to fetch rockets: ${e.toString()}');
    }
  }
}
