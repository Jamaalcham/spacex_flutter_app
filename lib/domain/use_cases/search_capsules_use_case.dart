import '../entities/capsule_entity.dart';
import '../repositories/capsule_repository.dart';
import 'base_use_case.dart';

/// Parameters for searching capsules
class SearchCapsulesParams {
  final String searchTerm;

  const SearchCapsulesParams({required this.searchTerm});
}

/// Use case for searching capsules by serial or type
/// 
/// This use case handles the business logic for searching capsules
/// with proper validation and filtering.
class SearchCapsulesUseCase extends BaseUseCase<List<CapsuleEntity>, SearchCapsulesParams> {
  final CapsuleRepository repository;

  SearchCapsulesUseCase(this.repository);

  @override
  Future<List<CapsuleEntity>> execute(SearchCapsulesParams params) async {
    // Input validation
    final searchTerm = params.searchTerm.trim();
    
    if (searchTerm.isEmpty) {
      // Return empty list for empty search terms
      return [];
    }

    try {
      final capsules = await repository.searchCapsules(searchTerm);
      
      // Business logic: Sort search results by relevance
      capsules.sort((a, b) {
        final aSerial = (a.serial ?? '').toLowerCase();
        final bSerial = (b.serial ?? '').toLowerCase();
        final search = searchTerm.toLowerCase();
        
        // Exact matches first
        if (aSerial == search && bSerial != search) return -1;
        if (bSerial == search && aSerial != search) return 1;
        
        // Then by serial alphabetically
        return aSerial.compareTo(bSerial);
      });
      
      return capsules;
    } catch (e) {
      throw Exception('Failed to search capsules: ${e.toString()}');
    }
  }
}
