import '../entities/capsule_entity.dart';
import '../repositories/capsule_repository.dart';
import 'base_use_case.dart';

/// Use case for getting all capsules
/// 
/// This use case handles the business logic for fetching all capsules
/// from the repository with proper sorting and validation.
class GetCapsulesUseCase extends BaseUseCaseNoParams<List<CapsuleEntity>> {
  final CapsuleRepository repository;

  GetCapsulesUseCase(this.repository);

  @override
  Future<List<CapsuleEntity>> execute() async {
    try {
      final capsules = await repository.getCapsulesWithPagination(limit: 100);
      
      // Business logic: Sort capsules by serial for consistent display
      capsules.sort((a, b) => (a.serial ?? '').compareTo(b.serial ?? ''));
      
      return capsules;
    } catch (e) {
      throw Exception('Failed to fetch capsules: ${e.toString()}');
    }
  }
}
