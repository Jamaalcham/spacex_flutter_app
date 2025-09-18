import '../entities/landpad_entity.dart';
import '../repositories/landpad_repository.dart';
import 'base_use_case.dart';

/// Use case for getting all landpads
/// 
/// This use case handles the business logic for fetching all landpads
/// from the repository with proper sorting and validation.
class GetLandpadsUseCase extends BaseUseCaseNoParams<List<LandpadEntity>> {
  final LandpadRepository repository;

  GetLandpadsUseCase(this.repository);

  @override
  Future<List<LandpadEntity>> execute() async {
    try {
      final landpads = await repository.getLandpads(limit: 100);
      
      // Business logic: Sort landpads by name for consistent display
      landpads.sort((a, b) => (a.fullName ?? '').compareTo(b.fullName ?? ''));
      
      return landpads;
    } catch (e) {
      throw Exception('Failed to fetch landpads: ${e.toString()}');
    }
  }
}
