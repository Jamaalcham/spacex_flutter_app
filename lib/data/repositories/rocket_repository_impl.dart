import 'package:dio/dio.dart';
import '../../core/network/rest_client.dart';
import '../../core/cache/rocket_cache_manager.dart';
import '../../core/network/connectivity_manager.dart';
import '../../domain/entities/rocket_entity.dart';
import '../../domain/repositories/rocket_repository.dart';
import '../../core/network/network_exceptions.dart';

// Implementation of RocketRepository using REST API with offline caching
// This class handles all rocket-related data operations using the SpaceX REST API.
class RocketRepositoryImpl implements RocketRepository {
  final RestClient _client;
  final RocketCacheManager _cacheManager;
  final ConnectivityManager _connectivityManager;

  RocketRepositoryImpl({
    RestClient? client,
    RocketCacheManager? cacheManager,
    ConnectivityManager? connectivityManager,
  }) : _client = client ?? RestClient.instance,
       _cacheManager = cacheManager ?? RocketCacheManager(),
       _connectivityManager = connectivityManager ?? ConnectivityManager();

  @override
  Future<List<RocketEntity>> getAllRockets() async {
    // Check if we have internet connectivity
    final hasConnection = await _connectivityManager.checkConnectivity();
    
    // Try to get cached data first if offline or as fallback
    if (!hasConnection) {
      final cachedRockets = await _cacheManager.getCachedRockets();
      if (cachedRockets != null) {
        return cachedRockets;
      }
      throw const NetworkException(message: 'No internet connection and no cached data available');
    }

    try {
      final response = await _client.post(
        '/rockets/query',
        data: {
          'query': {},
          'options': {
            'limit': 100,
            'page': 1,
            'sort': {'name': 1}
          }
        },
      );

      if (response.data == null || response.data['docs'] == null) {
        // Try to return cached data as fallback
        final cachedRockets = await _cacheManager.getCachedRockets();
        if (cachedRockets != null) {
          return cachedRockets;
        }
        throw const NetworkException(message: 'No rocket data received from server');
      }

      final List<dynamic> rocketsJson = response.data['docs'];
      
      // Cache the raw JSON data for offline use
      await _cacheManager.cacheRocketsJson(
        rocketsJson.cast<Map<String, dynamic>>()
      );
      
      return rocketsJson
          .map((json) => RocketEntity.fromJson(json))
          .toList();
    } on DioException catch (e) {
      // Try to return cached data as fallback
      final cachedRockets = await _cacheManager.getCachedRockets();
      if (cachedRockets != null) {
        return cachedRockets;
      }
      throw _handleDioException(e);
    } catch (e) {
      // Try to return cached data as fallback
      final cachedRockets = await _cacheManager.getCachedRockets();
      if (cachedRockets != null) {
        return cachedRockets;
      }
      throw NetworkException(message: 'Failed to fetch rockets: ${e.toString()}');
    }
  }

  @override
  Future<RocketEntity> getRocketById(String id) async {
    // Check if we have internet connectivity
    final hasConnection = await _connectivityManager.checkConnectivity();
    
    // Try to get cached data first if offline
    if (!hasConnection) {
      final cachedRocket = await _cacheManager.getCachedRocketById(id);
      if (cachedRocket != null) {
        return cachedRocket;
      }
      throw const NetworkException(message: 'No internet connection and no cached data available');
    }

    try {
      final response = await _client.get('/rockets/$id');

      if (response.data == null) {
        // Try to return cached data as fallback
        final cachedRocket = await _cacheManager.getCachedRocketById(id);
        if (cachedRocket != null) {
          return cachedRocket;
        }
        throw const NetworkException(message: 'Rocket not found');
      }

      // Cache the rocket data for offline use
      await _cacheManager.cacheRocketById(id, response.data);

      return RocketEntity.fromJson(response.data);
    } on DioException catch (e) {
      // Try to return cached data as fallback
      final cachedRocket = await _cacheManager.getCachedRocketById(id);
      if (cachedRocket != null) {
        return cachedRocket;
      }
      throw _handleDioException(e);
    } catch (e) {
      // Try to return cached data as fallback
      final cachedRocket = await _cacheManager.getCachedRocketById(id);
      if (cachedRocket != null) {
        return cachedRocket;
      }
      throw NetworkException(message: 'Failed to fetch rocket: ${e.toString()}');
    }
  }

  @override
  Future<List<RocketEntity>> getActiveRockets() async {
    try {
      final response = await _client.post(
        '/rockets/query',
        data: {
          'query': {'active': true},
          'options': {
            'limit': 100,
            'page': 1,
            'sort': {'name': 1}
          }
        },
      );

      if (response.data == null || response.data['docs'] == null) {
        return [];
      }

      final List<dynamic> rocketsJson = response.data['docs'];
      return rocketsJson
          .map((json) => RocketEntity.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw NetworkException(message: 'Failed to fetch active rockets: ${e.toString()}');
    }
  }

  @override
  Future<List<RocketEntity>> searchRockets(String searchTerm) async {
    try {
      final response = await _client.post(
        '/rockets/query',
        data: {
          'query': {
            '\$text': {'\$search': searchTerm}
          },
          'options': {
            'limit': 100,
            'page': 1,
            'sort': {'name': 1}
          }
        },
      );

      if (response.data == null || response.data['docs'] == null) {
        return [];
      }

      final List<dynamic> rocketsJson = response.data['docs'];
      return rocketsJson
          .map((json) => RocketEntity.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw NetworkException(message: 'Failed to search rockets: ${e.toString()}');
    }
  }

  @override
  Future<List<RocketEntity>> getRocketsByCompany(String company) async {
    try {
      final response = await _client.post(
        '/rockets/query',
        data: {
          'query': {'company': company},
          'options': {
            'limit': 100,
            'page': 1,
            'sort': {'name': 1}
          }
        },
      );

      if (response.data == null || response.data['docs'] == null) {
        return [];
      }

      final List<dynamic> rocketsJson = response.data['docs'];
      return rocketsJson
          .map((json) => RocketEntity.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw NetworkException(message: 'Failed to fetch rockets by company: ${e.toString()}');
    }
  }

  @override
  Future<List<RocketEntity>> getRocketsWithImages() async {
    try {
      final response = await _client.post(
        '/rockets/query',
        data: {
          'query': {
            'flickr_images': {'\$ne': []}
          },
          'options': {
            'limit': 100,
            'page': 1,
            'sort': {'name': 1}
          }
        },
      );

      if (response.data == null || response.data['docs'] == null) {
        return [];
      }

      final List<dynamic> rocketsJson = response.data['docs'];
      return rocketsJson
          .map((json) => RocketEntity.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw NetworkException(message: 'Failed to fetch rockets with images: ${e.toString()}');
    }
  }

  @override
  Future<List<RocketEntity>> refreshRockets() async {
    try {
      // For REST API, we simply fetch fresh data without cache
      final response = await _client.post(
        '/rockets/query',
        data: {
          'query': {},
          'options': {
            'limit': 100,
            'page': 1,
            'sort': {'name': 1}
          }
        },
      );

      if (response.data == null || response.data['docs'] == null) {
        throw const NetworkException(message: 'No rocket data received from server');
      }

      final List<dynamic> rocketsJson = response.data['docs'];
      return rocketsJson
          .map((json) => RocketEntity.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw NetworkException(message: 'Failed to refresh rockets: ${e.toString()}');
    }
  }

  /// Handles Dio exceptions and converts them to appropriate network exceptions
  NetworkException _handleDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(message: 'Connection timeout. Please check your internet connection.');
      
      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 500) {
            return NetworkException(message: 'Server error ($statusCode). Please try again later.');
          } else if (statusCode >= 400) {
            return NetworkException(message: 'Client error ($statusCode). Please check your request.');
          }
        }
        return const NetworkException(message: 'Bad response from server.');
      
      case DioExceptionType.cancel:
        return const NetworkException(message: 'Request was cancelled.');
      
      case DioExceptionType.connectionError:
        return const NetworkException(message: 'Connection error. Please check your internet connection.');
      
      case DioExceptionType.badCertificate:
        return const NetworkException(message: 'Certificate error. Please check your connection security.');
      
      case DioExceptionType.unknown:
        return NetworkException(message: 'Unknown error occurred: ${exception.message}');
    }
  }
}