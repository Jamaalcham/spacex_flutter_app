import '../entities/rocket_entity.dart';
import '../repositories/rocket_repository.dart';
import 'base_use_case.dart';

/// Parameters for getting a rocket by ID
class GetRocketByIdParams {
  final String id;

  const GetRocketByIdParams({required this.id});
}

/// Use case for getting a specific rocket by ID
/// 
/// This use case handles the business logic for fetching a specific rocket
/// by its ID with proper validation and error handling.
class GetRocketByIdUseCase extends BaseUseCase<RocketEntity, GetRocketByIdParams> {
  final RocketRepository repository;

  GetRocketByIdUseCase(this.repository);

  @override
  Future<RocketEntity> execute(GetRocketByIdParams params) async {
    // Input validation
    if (params.id.isEmpty) {
      throw ArgumentError('Rocket ID cannot be empty');
    }

    try {
      final rocket = await repository.getRocketById(params.id);
      
      if (rocket == null) {
        throw Exception('Rocket with ID ${params.id} not found');
      }
      
      return rocket;
    } catch (e) {
      // Re-throw with additional context
      throw Exception('Failed to fetch rocket with ID ${params.id}: ${e.toString()}');
    }
  }
}
