import 'package:dio/dio.dart';
import '../../domain/entities/capsule_entity.dart';
import '../../domain/repositories/capsule_repository.dart';
import '../../core/utils/exceptions.dart';
import '../../core/network/rest_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/network_exceptions.dart' as network;
import '../../core/cache/capsule_cache_manager.dart';
import '../../core/network/connectivity_manager.dart';

// Implementation of [CapsuleRepository] using REST API with offline caching
//
// This implementation provides capsule data access through SpaceX REST API.
// It handles network requests, data parsing, error handling, and offline caching.
class CapsuleRepositoryImpl implements CapsuleRepository {
  final RestClient _client;
  final CapsuleCacheManager _cacheManager;
  final ConnectivityManager _connectivityManager;

  CapsuleRepositoryImpl({
    RestClient? client,
    CapsuleCacheManager? cacheManager,
    ConnectivityManager? connectivityManager,
  }) : _client = client ?? RestClient.instance,
       _cacheManager = cacheManager ?? CapsuleCacheManager(),
       _connectivityManager = connectivityManager ?? ConnectivityManager();

  @override
  Future<List<CapsuleEntity>> getCapsulesWithPagination({
    int limit = 20,
    int offset = 0,
  }) async {
    // Check if we have internet connectivity
    final hasConnection = await _connectivityManager.checkConnectivity();
    
    // Try to get cached data first if offline
    if (!hasConnection) {
      final cachedCapsules = await _cacheManager.getCachedCapsules();
      if (cachedCapsules != null) {
        // Apply pagination to cached data
        final endIndex = (offset + limit).clamp(0, cachedCapsules.length);
        final startIndex = offset.clamp(0, cachedCapsules.length);
        
        if (startIndex >= cachedCapsules.length) {
          return [];
        }
        
        return cachedCapsules.sublist(startIndex, endIndex);
      }
      throw const network.NetworkException(message: 'No internet connection and no cached data available');
    }

    try {
      // Calculate page number for API (1-based)
      final page = (offset ~/ limit) + 1;
      
      final response = await _client.post(
        ApiEndpoints.capsulesQuery,
        data: {
          'query': {},
          'options': {
            'limit': limit,
            'page': page,
            'sort': {'serial': 1}
          }
        },
      );

      if (response.data == null || response.data['docs'] == null) {
        // Try to return cached data as fallback
        final cachedCapsules = await _cacheManager.getCachedCapsules();
        if (cachedCapsules != null) {
          final endIndex = (offset + limit).clamp(0, cachedCapsules.length);
          final startIndex = offset.clamp(0, cachedCapsules.length);
          
          if (startIndex >= cachedCapsules.length) {
            return [];
          }
          
          return cachedCapsules.sublist(startIndex, endIndex);
        }
        throw const network.NetworkException(message: 'No capsule data received from server');
      }

      final List<dynamic> capsulesJson = response.data['docs'];
      
      // Cache the raw JSON data for offline use (only for first page)
      if (page == 1) {
        await _cacheManager.cacheCapsulesJson(
          capsulesJson.cast<Map<String, dynamic>>()
        );
      }
      
      return capsulesJson
          .map((json) => CapsuleEntity.fromJson(json))
          .toList();
    } on DioException catch (e) {
      // Try to return cached data as fallback
      final cachedCapsules = await _cacheManager.getCachedCapsules();
      if (cachedCapsules != null) {
        final endIndex = (offset + limit).clamp(0, cachedCapsules.length);
        final startIndex = offset.clamp(0, cachedCapsules.length);
        
        if (startIndex >= cachedCapsules.length) {
          return [];
        }
        
        return cachedCapsules.sublist(startIndex, endIndex);
      }
      throw _handleDioException(e);
    } catch (e) {
      // Try to return cached data as fallback
      final cachedCapsules = await _cacheManager.getCachedCapsules();
      if (cachedCapsules != null) {
        final endIndex = (offset + limit).clamp(0, cachedCapsules.length);
        final startIndex = offset.clamp(0, cachedCapsules.length);
        
        if (startIndex >= cachedCapsules.length) {
          return [];
        }
        
        return cachedCapsules.sublist(startIndex, endIndex);
      }
      throw network.NetworkException(message: 'Failed to fetch capsules: ${e.toString()}');
    }
  }

  @override
  Future<List<CapsuleEntity>> searchCapsules(String query) async {
    // Check if we have internet connectivity
    final hasConnection = await _connectivityManager.checkConnectivity();
    
    // Try to get cached data first if offline
    if (!hasConnection) {
      final cachedCapsules = await _cacheManager.getCachedCapsules();
      if (cachedCapsules != null) {
        // Filter cached data
        final lowercaseQuery = query.toLowerCase();
        return cachedCapsules.where((capsule) {
          final serial = capsule.serial?.toLowerCase() ?? '';
          final type = capsule.type?.toLowerCase() ?? '';
          final details = capsule.details?.toLowerCase() ?? '';
          
          return serial.contains(lowercaseQuery) ||
                 type.contains(lowercaseQuery) ||
                 details.contains(lowercaseQuery);
        }).toList();
      }
      throw const network.NetworkException(message: 'No internet connection and no cached data available');
    }

    try {
      final response = await _client.post(
        ApiEndpoints.capsulesQuery,
        data: {
          'query': {
            '\$text': {'\$search': query}
          },
          'options': {
            'limit': 100,
            'page': 1,
            'sort': {'serial': 1}
          }
        },
      );

      if (response.data == null || response.data['docs'] == null) {
        // Try to return cached data as fallback
        final cachedCapsules = await _cacheManager.getCachedCapsules();
        if (cachedCapsules != null) {
          final lowercaseQuery = query.toLowerCase();
          return cachedCapsules.where((capsule) {
            final serial = capsule.serial?.toLowerCase() ?? '';
            final type = capsule.type?.toLowerCase() ?? '';
            final details = capsule.details?.toLowerCase() ?? '';
            
            return serial.contains(lowercaseQuery) ||
                   type.contains(lowercaseQuery) ||
                   details.contains(lowercaseQuery);
          }).toList();
        }
        throw const network.NetworkException(message: 'No search results from server');
      }

      final List<dynamic> capsulesJson = response.data['docs'];
      return capsulesJson
          .map((json) => CapsuleEntity.fromJson(json))
          .toList();
    } on DioException catch (e) {
      // Try to return cached data as fallback
      final cachedCapsules = await _cacheManager.getCachedCapsules();
      if (cachedCapsules != null) {
        final lowercaseQuery = query.toLowerCase();
        return cachedCapsules.where((capsule) {
          final serial = capsule.serial?.toLowerCase() ?? '';
          final type = capsule.type?.toLowerCase() ?? '';
          final details = capsule.details?.toLowerCase() ?? '';
          
          return serial.contains(lowercaseQuery) ||
                 type.contains(lowercaseQuery) ||
                 details.contains(lowercaseQuery);
        }).toList();
      }
      throw _handleDioException(e);
    } catch (e) {
      throw network.NetworkException(message: 'Failed to search capsules: ${e.toString()}');
    }
  }

  @override
  Future<CapsuleEntity> getCapsuleById(String id) async {
    // Check if we have internet connectivity
    final hasConnection = await _connectivityManager.checkConnectivity();
    
    // Try to get cached data first if offline
    if (!hasConnection) {
      final cachedCapsules = await _cacheManager.getCachedCapsules();
      if (cachedCapsules != null) {
        try {
          return cachedCapsules.firstWhere((capsule) => capsule.id == id);
        } catch (e) {
          throw NotFoundException('Capsule with id $id not found in cache');
        }
      }
      throw const network.NetworkException(message: 'No internet connection and no cached data available');
    }

    try {
      final response = await _client.get('${ApiEndpoints.capsules}/$id');

      if (response.data == null) {
        throw NotFoundException('Capsule with id $id not found');
      }

      return CapsuleEntity.fromJson(response.data);
    } on DioException catch (e) {
      // Try to return cached data as fallback
      final cachedCapsules = await _cacheManager.getCachedCapsules();
      if (cachedCapsules != null) {
        try {
          return cachedCapsules.firstWhere((capsule) => capsule.id == id);
        } catch (_) {
          // Continue to throw the original error
        }
      }
      throw _handleDioException(e);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw network.NetworkException(message: 'Failed to fetch capsule: ${e.toString()}');
    }
  }

  @override
  Future<List<CapsuleEntity>> getCapsulesByStatus({
    required String status,
    int limit = 20,
    int offset = 0,
  }) async {
    // Check if we have internet connectivity
    final hasConnection = await _connectivityManager.checkConnectivity();
    
    // Try to get cached data first if offline
    if (!hasConnection) {
      final cachedCapsules = await _cacheManager.getCachedCapsules();
      if (cachedCapsules != null) {
        final filteredCapsules = cachedCapsules
            .where((capsule) => capsule.status?.toLowerCase() == status.toLowerCase())
            .toList();
        
        final endIndex = (offset + limit).clamp(0, filteredCapsules.length);
        final startIndex = offset.clamp(0, filteredCapsules.length);
        
        if (startIndex >= filteredCapsules.length) {
          return [];
        }
        
        return filteredCapsules.sublist(startIndex, endIndex);
      }
      throw const network.NetworkException(message: 'No internet connection and no cached data available');
    }

    try {
      final page = (offset ~/ limit) + 1;
      
      final response = await _client.post(
        ApiEndpoints.capsulesQuery,
        data: {
          'query': {'status': status},
          'options': {
            'limit': limit,
            'page': page,
            'sort': {'serial': 1}
          }
        },
      );

      if (response.data == null || response.data['docs'] == null) {
        // Try to return cached data as fallback
        final cachedCapsules = await _cacheManager.getCachedCapsules();
        if (cachedCapsules != null) {
          final filteredCapsules = cachedCapsules
              .where((capsule) => capsule.status?.toLowerCase() == status.toLowerCase())
              .toList();
          
          final endIndex = (offset + limit).clamp(0, filteredCapsules.length);
          final startIndex = offset.clamp(0, filteredCapsules.length);
          
          if (startIndex >= filteredCapsules.length) {
            return [];
          }
          
          return filteredCapsules.sublist(startIndex, endIndex);
        }
        throw const network.NetworkException(message: 'No capsule data received from server');
      }

      final List<dynamic> capsulesJson = response.data['docs'];
      return capsulesJson
          .map((json) => CapsuleEntity.fromJson(json))
          .toList();
    } on DioException catch (e) {
      // Try to return cached data as fallback
      final cachedCapsules = await _cacheManager.getCachedCapsules();
      if (cachedCapsules != null) {
        final filteredCapsules = cachedCapsules
            .where((capsule) => capsule.status?.toLowerCase() == status.toLowerCase())
            .toList();
        
        final endIndex = (offset + limit).clamp(0, filteredCapsules.length);
        final startIndex = offset.clamp(0, filteredCapsules.length);
        
        if (startIndex >= filteredCapsules.length) {
          return [];
        }
        
        return filteredCapsules.sublist(startIndex, endIndex);
      }
      throw _handleDioException(e);
    } catch (e) {
      throw network.NetworkException(message: 'Failed to fetch capsules by status: ${e.toString()}');
    }
  }

  @override
  Future<List<CapsuleEntity>> getReusedCapsules({
    int limit = 20,
    int offset = 0,
  }) async {
    // Check if we have internet connectivity
    final hasConnection = await _connectivityManager.checkConnectivity();
    
    // Try to get cached data first if offline
    if (!hasConnection) {
      final cachedCapsules = await _cacheManager.getCachedCapsules();
      if (cachedCapsules != null) {
        final reusedCapsules = cachedCapsules
            .where((capsule) => (capsule.reuseCount ?? 0) > 0)
            .toList();
        
        final endIndex = (offset + limit).clamp(0, reusedCapsules.length);
        final startIndex = offset.clamp(0, reusedCapsules.length);
        
        if (startIndex >= reusedCapsules.length) {
          return [];
        }
        
        return reusedCapsules.sublist(startIndex, endIndex);
      }
      throw const network.NetworkException(message: 'No internet connection and no cached data available');
    }

    try {
      final page = (offset ~/ limit) + 1;
      
      final response = await _client.post(
        ApiEndpoints.capsulesQuery,
        data: {
          'query': {
            'reuse_count': {'\$gt': 0}
          },
          'options': {
            'limit': limit,
            'page': page,
            'sort': {'reuse_count': -1}
          }
        },
      );

      if (response.data == null || response.data['docs'] == null) {
        // Try to return cached data as fallback
        final cachedCapsules = await _cacheManager.getCachedCapsules();
        if (cachedCapsules != null) {
          final reusedCapsules = cachedCapsules
              .where((capsule) => (capsule.reuseCount ?? 0) > 0)
              .toList();
          
          final endIndex = (offset + limit).clamp(0, reusedCapsules.length);
          final startIndex = offset.clamp(0, reusedCapsules.length);
          
          if (startIndex >= reusedCapsules.length) {
            return [];
          }
          
          return reusedCapsules.sublist(startIndex, endIndex);
        }
        throw const network.NetworkException(message: 'No capsule data received from server');
      }

      final List<dynamic> capsulesJson = response.data['docs'];
      return capsulesJson
          .map((json) => CapsuleEntity.fromJson(json))
          .toList();
    } on DioException catch (e) {
      // Try to return cached data as fallback
      final cachedCapsules = await _cacheManager.getCachedCapsules();
      if (cachedCapsules != null) {
        final reusedCapsules = cachedCapsules
            .where((capsule) => (capsule.reuseCount ?? 0) > 0)
            .toList();
        
        final endIndex = (offset + limit).clamp(0, reusedCapsules.length);
        final startIndex = offset.clamp(0, reusedCapsules.length);
        
        if (startIndex >= reusedCapsules.length) {
          return [];
        }
        
        return reusedCapsules.sublist(startIndex, endIndex);
      }
      throw _handleDioException(e);
    } catch (e) {
      throw network.NetworkException(message: 'Failed to fetch reused capsules: ${e.toString()}');
    }
  }

  // Handles Dio exceptions and converts them to appropriate NetworkExceptions
  network.NetworkException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const network.NetworkException(message: 'Connection timeout. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) {
          return const network.NetworkException(message: 'Capsule not found');
        } else if (statusCode == 500) {
          return const network.NetworkException(message: 'Server error. Please try again later.');
        }
        return network.NetworkException(message: 'HTTP Error: $statusCode');
      case DioExceptionType.cancel:
        return const network.NetworkException(message: 'Request was cancelled');
      case DioExceptionType.connectionError:
        return const network.NetworkException(message: 'No internet connection');
      case DioExceptionType.badCertificate:
        return const network.NetworkException(message: 'Certificate error');
      case DioExceptionType.unknown:
        return network.NetworkException(message: 'Network error: ${e.message}');
    }
  }
}
