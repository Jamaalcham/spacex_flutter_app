import '../entities/rocket_entity.dart';
import '../repositories/rocket_repository.dart';
import 'base_use_case.dart';

/// Parameters for searching rockets
class SearchRocketsParams {
  final String searchTerm;

  const SearchRocketsParams({required this.searchTerm});
}

/// Use case for searching rockets by name or type
/// 
/// This use case handles the business logic for searching rockets
/// with proper validation and filtering.
class SearchRocketsUseCase extends BaseUseCase<List<RocketEntity>, SearchRocketsParams> {
  final RocketRepository repository;

  SearchRocketsUseCase(this.repository);

  @override
  Future<List<RocketEntity>> execute(SearchRocketsParams params) async {
    // Input validation
    final searchTerm = params.searchTerm.trim();
    
    if (searchTerm.isEmpty) {
      // Return empty list for empty search terms
      return [];
    }

    try {
      final rockets = await repository.searchRockets(searchTerm);
      
      // Business logic: Sort search results by relevance
      // First by exact name matches, then by partial matches
      rockets.sort((a, b) {
        final aName = (a.name).toLowerCase();
        final bName = (b.name).toLowerCase();
        final search = searchTerm.toLowerCase();
        
        // Exact matches first
        if (aName == search && bName != search) return -1;
        if (bName == search && aName != search) return 1;
        
        // Then by name alphabetically
        return aName.compareTo(bName);
      });
      
      return rockets;
    } catch (e) {
      throw Exception('Failed to search rockets: ${e.toString()}');
    }
  }
}
