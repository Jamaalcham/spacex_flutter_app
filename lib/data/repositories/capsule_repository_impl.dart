import '../../domain/entities/capsule_entity.dart';
import '../../domain/repositories/capsule_repository.dart';
import '../../core/utils/exceptions.dart';

/// Implementation of [CapsuleRepository] using REST API
/// 
/// This implementation provides capsule data access through SpaceX REST API.
/// It handles network requests, data parsing, and error handling.
class CapsuleRepositoryImpl implements CapsuleRepository {
  // Mock data for development - replace with actual API calls
  static final List<CapsuleEntity> _mockCapsules = [
    const CapsuleEntity(
      id: '1',
      serial: 'C101',
      type: 'Dragon 1.0',
      status: 'retired',
      reuseCount: 0,
      waterLandings: 1,
      landLandings: 0,
      launches: ['launch1'],
      details: 'First Dragon capsule to fly',
    ),
    const CapsuleEntity(
      id: '2',
      serial: 'C102',
      type: 'Dragon 1.1',
      status: 'destroyed',
      reuseCount: 0,
      waterLandings: 0,
      landLandings: 0,
      launches: ['launch2'],
      details: 'Lost during mission',
    ),
    const CapsuleEntity(
      id: '3',
      serial: 'C201',
      type: 'Dragon 2.0',
      status: 'active',
      reuseCount: 3,
      waterLandings: 2,
      landLandings: 1,
      launches: ['launch3', 'launch4', 'launch5'],
      details: 'Currently active Dragon 2.0 capsule',
    ),
    const CapsuleEntity(
      id: '4',
      serial: 'C202',
      type: 'Dragon 2.0',
      status: 'active',
      reuseCount: 2,
      waterLandings: 1,
      landLandings: 1,
      launches: ['launch6', 'launch7'],
      details: 'Active Dragon 2.0 capsule with multiple flights',
    ),
    const CapsuleEntity(
      id: '5',
      serial: 'C203',
      type: 'Dragon 2.0',
      status: 'active',
      reuseCount: 1,
      waterLandings: 0,
      landLandings: 1,
      launches: ['launch8'],
      details: 'Newest Dragon 2.0 capsule',
    ),
  ];

  @override
  Future<List<CapsuleEntity>> getCapsulesWithPagination({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Simulate pagination
      final endIndex = (offset + limit).clamp(0, _mockCapsules.length);
      final startIndex = offset.clamp(0, _mockCapsules.length);
      
      if (startIndex >= _mockCapsules.length) {
        return [];
      }
      
      return _mockCapsules.sublist(startIndex, endIndex);
    } catch (e) {
      throw ServerException('Failed to fetch capsules: $e');
    }
  }

  @override
  Future<List<CapsuleEntity>> searchCapsules(String query) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      final lowercaseQuery = query.toLowerCase();
      
      return _mockCapsules.where((capsule) {
        final serial = capsule.serial?.toLowerCase() ?? '';
        final type = capsule.type?.toLowerCase() ?? '';
        final details = capsule.details?.toLowerCase() ?? '';
        
        return serial.contains(lowercaseQuery) ||
               type.contains(lowercaseQuery) ||
               details.contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      throw ServerException('Failed to search capsules: $e');
    }
  }

  @override
  Future<CapsuleEntity> getCapsuleById(String id) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 200));
      
      final capsule = _mockCapsules.firstWhere(
        (capsule) => capsule.id == id,
        orElse: () => throw NotFoundException('Capsule with id $id not found'),
      );
      
      return capsule;
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException('Failed to fetch capsule: $e');
    }
  }

  @override
  Future<List<CapsuleEntity>> getCapsulesByStatus({
    required String status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 400));
      
      final filteredCapsules = _mockCapsules
          .where((capsule) => capsule.status?.toLowerCase() == status.toLowerCase())
          .toList();
      
      // Apply pagination
      final endIndex = (offset + limit).clamp(0, filteredCapsules.length);
      final startIndex = offset.clamp(0, filteredCapsules.length);
      
      if (startIndex >= filteredCapsules.length) {
        return [];
      }
      
      return filteredCapsules.sublist(startIndex, endIndex);
    } catch (e) {
      throw ServerException('Failed to fetch capsules by status: $e');
    }
  }

  @override
  Future<List<CapsuleEntity>> getReusedCapsules({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 400));
      
      final reusedCapsules = _mockCapsules
          .where((capsule) => (capsule.reuseCount ?? 0) > 0)
          .toList();
      
      // Apply pagination
      final endIndex = (offset + limit).clamp(0, reusedCapsules.length);
      final startIndex = offset.clamp(0, reusedCapsules.length);
      
      if (startIndex >= reusedCapsules.length) {
        return [];
      }
      
      return reusedCapsules.sublist(startIndex, endIndex);
    } catch (e) {
      throw ServerException('Failed to fetch reused capsules: $e');
    }
  }
}
