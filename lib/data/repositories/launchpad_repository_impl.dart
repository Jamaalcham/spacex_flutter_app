import 'package:graphql_flutter/graphql_flutter.dart';

import '../../core/network/graphql_client.dart';
import '../../domain/entities/launchpad_entity.dart';
import '../../domain/repositories/launchpad_repository.dart';
import '../models/launchpad_model.dart';
import '../queries/launches_query.dart';
import '../../core/utils/exceptions.dart' as app_exceptions;
import '../../core/cache/launchpad_cache_manager.dart';
import '../../core/network/connectivity_manager.dart';

// Implementation of LaunchpadRepository using GraphQL with offline caching
class LaunchpadRepositoryImpl implements LaunchpadRepository {
  final GraphQLClient _client;
  final LaunchpadCacheManager _cacheManager;
  final ConnectivityManager _connectivityManager;

  LaunchpadRepositoryImpl({
    GraphQLClient? client,
    LaunchpadCacheManager? cacheManager,
    ConnectivityManager? connectivityManager,
  }) : _client = client ?? GraphQLService.client,
       _cacheManager = cacheManager ?? LaunchpadCacheManager(),
       _connectivityManager = connectivityManager ?? ConnectivityManager();

  @override
  Future<List<LaunchpadEntity>> getLaunchpads({
    int limit = 20,
    int offset = 0,
  }) async {
    // Check if we have internet connectivity
    final hasConnection = await _connectivityManager.checkConnectivity();
    
    // Try to get cached data first if offline
    if (!hasConnection) {
      final cachedLaunchpads = await _cacheManager.getCachedLaunchpads();
      if (cachedLaunchpads != null) {
        // Apply pagination to cached data
        final endIndex = (offset + limit).clamp(0, cachedLaunchpads.length);
        final startIndex = offset.clamp(0, cachedLaunchpads.length);
        
        if (startIndex >= cachedLaunchpads.length) {
          return [];
        }
        
        return cachedLaunchpads.sublist(startIndex, endIndex);
      }
      throw app_exceptions.NetworkException('No internet connection and no cached data available');
    }

    try {
      final result = await _client.query(QueryOptions(
        document: gql(launchpadsQuery),
        variables: {
          'limit': limit,
          'offset': offset,
        },
        fetchPolicy: FetchPolicy.networkOnly, // Always fetch fresh data
        errorPolicy: ErrorPolicy.all,
      ));

      if (result.hasException) {
        // Try to return cached data as fallback
        final cachedLaunchpads = await _cacheManager.getCachedLaunchpads();
        if (cachedLaunchpads != null) {
          final endIndex = (offset + limit).clamp(0, cachedLaunchpads.length);
          final startIndex = offset.clamp(0, cachedLaunchpads.length);
          
          if (startIndex >= cachedLaunchpads.length) {
            return [];
          }
          
          return cachedLaunchpads.sublist(startIndex, endIndex);
        }
        throw _handleGraphQLException(result.exception!);
      }

      if (result.data == null || result.data!['launchpads'] == null) {
        // Try to return cached data as fallback
        final cachedLaunchpads = await _cacheManager.getCachedLaunchpads();
        if (cachedLaunchpads != null) {
          final endIndex = (offset + limit).clamp(0, cachedLaunchpads.length);
          final startIndex = offset.clamp(0, cachedLaunchpads.length);
          
          if (startIndex >= cachedLaunchpads.length) {
            return [];
          }
          
          return cachedLaunchpads.sublist(startIndex, endIndex);
        }
        return [];
      }

      final List<dynamic> launchpadsJson = result.data!['launchpads'];
      final List<LaunchpadModel> launchpads = launchpadsJson
          .map((json) => LaunchpadModel.fromJson(json))
          .toList();

      // Cache the launchpads data for offline use (only for first page)
      if (offset == 0 && launchpads.isNotEmpty) {
        final launchpadsJsonForCache = launchpads.map((launchpad) => _mapToJson(launchpad)).toList();
        await _cacheManager.cacheLaunchpadsJson(launchpadsJsonForCache);
      }

      return launchpads;
    } catch (e) {
      // Try to return cached data as fallback
      final cachedLaunchpads = await _cacheManager.getCachedLaunchpads();
      if (cachedLaunchpads != null) {
        final endIndex = (offset + limit).clamp(0, cachedLaunchpads.length);
        final startIndex = offset.clamp(0, cachedLaunchpads.length);
        
        if (startIndex >= cachedLaunchpads.length) {
          return [];
        }
        
        return cachedLaunchpads.sublist(startIndex, endIndex);
      }
      
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to fetch launchpads: ${e.toString()}');
    }
  }

  @override
  Future<List<LaunchpadEntity>> refreshLaunchpads() async {
    try {
      // Clear cache before fetching fresh data
      GraphQLService.clearCache();

      final result = await _client.query(QueryOptions(
        document: gql(launchpadsQuery),
        variables: {
          'limit': 50,
          'offset': 0,
        },
        fetchPolicy: FetchPolicy.networkOnly,
        errorPolicy: ErrorPolicy.all,
      ));

      if (result.hasException) {
        throw _handleGraphQLException(result.exception!);
      }

      if (result.data == null || result.data!['launchpads'] == null) {
        return [];
      }

      final List<dynamic> launchpadsJson = result.data!['launchpads'];
      final List<LaunchpadModel> launchpads = launchpadsJson
          .map((json) => LaunchpadModel.fromJson(json))
          .toList();

      return launchpads;
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to refresh launchpads: ${e.toString()}');
    }
  }

  /// Handles GraphQL exceptions and converts them to appropriate app exceptions
  app_exceptions.AppException _handleGraphQLException(OperationException exception) {
    if (exception.linkException != null) {
      final linkException = exception.linkException!;

      if (linkException is NetworkException) {
        return const app_exceptions.NetworkException('Network error: Please check your internet connection');
      }

      if (linkException is ServerException) {
        return app_exceptions.ServerException('Server error: ${linkException.toString()}');
      }

      return app_exceptions.NetworkException('Connection error: ${linkException.toString()}');
    }

    if (exception.graphqlErrors.isNotEmpty) {
      final error = exception.graphqlErrors.first;
      return app_exceptions.ServerException('GraphQL error: ${error.message}');
    }

    return app_exceptions.ServerException('Unknown error occurred');
  }

  /// Maps LaunchpadEntity to JSON for caching
  Map<String, dynamic> _mapToJson(LaunchpadEntity launchpad) {
    return {
      'id': launchpad.id,
      'name': launchpad.name,
      'details': launchpad.details,
      'status': launchpad.status,
      'successful_launches': launchpad.successfulLaunches,
      'location': launchpad.location != null ? {
        'name': launchpad.location!.name,
        'region': launchpad.location!.region,
      } : null,
    };
  }
}
