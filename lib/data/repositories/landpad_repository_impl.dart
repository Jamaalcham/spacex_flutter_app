import 'package:graphql_flutter/graphql_flutter.dart';

import '../../core/network/graphql_client.dart';
import '../../domain/entities/landpad_entity.dart';
import '../../domain/repositories/landpad_repository.dart';
import '../models/landpad_model.dart';
import '../queries/launches_query.dart';
import '../../core/utils/exceptions.dart' as app_exceptions;
import '../../core/cache/landpad_cache_manager.dart';
import '../../core/network/connectivity_manager.dart';

// Implementation of LandpadRepository using GraphQL with offline caching
class LandpadRepositoryImpl implements LandpadRepository {
  final GraphQLClient _client;
  final LandpadCacheManager _cacheManager;
  final ConnectivityManager _connectivityManager;

  LandpadRepositoryImpl({
    GraphQLClient? client,
    LandpadCacheManager? cacheManager,
    ConnectivityManager? connectivityManager,
  }) : _client = client ?? GraphQLService.client,
       _cacheManager = cacheManager ?? LandpadCacheManager(),
       _connectivityManager = connectivityManager ?? ConnectivityManager();

  @override
  Future<List<LandpadEntity>> getLandpads({
    int limit = 20,
    int offset = 0,
  }) async {
    // Check if we have internet connectivity
    final hasConnection = await _connectivityManager.checkConnectivity();
    
    // Try to get cached data first if offline
    if (!hasConnection) {
      final cachedLandpads = await _cacheManager.getCachedLandpads();
      if (cachedLandpads != null) {
        // Apply pagination to cached data
        final endIndex = (offset + limit).clamp(0, cachedLandpads.length);
        final startIndex = offset.clamp(0, cachedLandpads.length);
        
        if (startIndex >= cachedLandpads.length) {
          return [];
        }
        
        return cachedLandpads.sublist(startIndex, endIndex);
      }
      throw app_exceptions.NetworkException('No internet connection and no cached data available');
    }

    try {
      final result = await _client.query(QueryOptions(
        document: gql(landpadsQuery),
        variables: {
          'limit': limit,
          'offset': offset,
        },
        fetchPolicy: FetchPolicy.networkOnly, // Always fetch fresh data
        errorPolicy: ErrorPolicy.all,
      ));

      if (result.hasException) {
        // Try to return cached data as fallback
        final cachedLandpads = await _cacheManager.getCachedLandpads();
        if (cachedLandpads != null) {
          final endIndex = (offset + limit).clamp(0, cachedLandpads.length);
          final startIndex = offset.clamp(0, cachedLandpads.length);
          
          if (startIndex >= cachedLandpads.length) {
            return [];
          }
          
          return cachedLandpads.sublist(startIndex, endIndex);
        }
        throw _handleGraphQLException(result.exception!);
      }

      if (result.data == null || result.data!['landpads'] == null) {
        // Try to return cached data as fallback
        final cachedLandpads = await _cacheManager.getCachedLandpads();
        if (cachedLandpads != null) {
          final endIndex = (offset + limit).clamp(0, cachedLandpads.length);
          final startIndex = offset.clamp(0, cachedLandpads.length);
          
          if (startIndex >= cachedLandpads.length) {
            return [];
          }
          
          return cachedLandpads.sublist(startIndex, endIndex);
        }
        return [];
      }

      final List<dynamic> landpadsJson = result.data!['landpads'];
      final List<LandpadModel> landpads = landpadsJson
          .map((json) => LandpadModel.fromJson(json))
          .toList();

      // Cache the landpads data for offline use (only for first page)
      if (offset == 0 && landpads.isNotEmpty) {
        final landpadsJsonForCache = landpads.map((landpad) => _mapToJson(landpad)).toList();
        await _cacheManager.cacheLandpadsJson(landpadsJsonForCache);
      }

      return landpads;
    } catch (e) {
      // Try to return cached data as fallback
      final cachedLandpads = await _cacheManager.getCachedLandpads();
      if (cachedLandpads != null) {
        final endIndex = (offset + limit).clamp(0, cachedLandpads.length);
        final startIndex = offset.clamp(0, cachedLandpads.length);
        
        if (startIndex >= cachedLandpads.length) {
          return [];
        }
        
        return cachedLandpads.sublist(startIndex, endIndex);
      }
      
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to fetch landpads: ${e.toString()}');
    }
  }

  @override
  Future<List<LandpadEntity>> refreshLandpads() async {
    try {
      // Clear cache before fetching fresh data
      GraphQLService.clearCache();

      final result = await _client.query(QueryOptions(
        document: gql(landpadsQuery),
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

      if (result.data == null || result.data!['landpads'] == null) {
        return [];
      }

      final List<dynamic> landpadsJson = result.data!['landpads'];
      final List<LandpadModel> landpads = landpadsJson
          .map((json) => LandpadModel.fromJson(json))
          .toList();

      return landpads;
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to refresh landpads: ${e.toString()}');
    }
  }

  //  Handles GraphQL exceptions and converts them to appropriate app exceptions
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

    return const app_exceptions.ServerException('Unknown error occurred');
  }

  // Maps LandpadEntity to JSON for caching
  Map<String, dynamic> _mapToJson(LandpadEntity landpad) {
    return {
      'id': landpad.id,
      'full_name': landpad.fullName,
      'details': landpad.details,
      'landing_type': landpad.landingType,
      'status': landpad.status,
      'successful_landings': landpad.successfulLandings,
      'location': landpad.location != null ? {
        'name': landpad.location!.name,
        'region': landpad.location!.region,
      } : null,
    };
  }
}
