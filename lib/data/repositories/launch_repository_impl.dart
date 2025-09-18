import 'package:graphql_flutter/graphql_flutter.dart';

import '../../core/network/graphql_client.dart';
import '../../domain/entities/launch_entity.dart';
import '../../domain/repositories/launch_repository.dart';
import '../models/launch_model.dart';
import '../queries/launches_query.dart';
import '../../core/utils/exceptions.dart' as app_exceptions;
import '../../core/cache/launch_cache_manager.dart';
import '../../core/network/connectivity_manager.dart';

// Implementation of LaunchRepository using GraphQL with offline caching

// data models and domain entities, and offline caching support.
class LaunchRepositoryImpl implements LaunchRepository {
  final GraphQLClient _client;
  final LaunchCacheManager _cacheManager;
  final ConnectivityManager _connectivityManager;

  LaunchRepositoryImpl({
    GraphQLClient? client,
    LaunchCacheManager? cacheManager,
    ConnectivityManager? connectivityManager,
  }) : _client = client ?? GraphQLService.client,
       _cacheManager = cacheManager ?? LaunchCacheManager(),
       _connectivityManager = connectivityManager ?? ConnectivityManager();

  @override
  Future<List<LaunchEntity>> getLaunchesWithPagination({
    int limit = 20,
    int offset = 0,
  }) async {
    // Check if we have internet connectivity
    final hasConnection = await _connectivityManager.checkConnectivity();
    
    // Try to get cached data first if offline
    if (!hasConnection) {
      final cachedLaunches = await _cacheManager.getCachedLaunches();
      if (cachedLaunches != null) {
        // Apply pagination to cached data
        final endIndex = (offset + limit).clamp(0, cachedLaunches.length);
        final startIndex = offset.clamp(0, cachedLaunches.length);
        
        if (startIndex >= cachedLaunches.length) {
          return [];
        }
        
        return cachedLaunches.sublist(startIndex, endIndex);
      }
      throw app_exceptions.NetworkException('No internet connection and no cached data available');
    }

    try {
      // For initial load, get upcoming launches first (they're usually fewer)
      // Then get paginated past launches
      final List<LaunchEntity> allLaunches = [];
      
      if (offset == 0) {
        // First page: get upcoming launches
        final upcomingResult = await _client.query(QueryOptions(
          document: gql(upcomingLaunchesQuery),
          variables: {'limit': 10}, // Limit upcoming to 10
          fetchPolicy: FetchPolicy.networkOnly, // Always fetch fresh data
          errorPolicy: ErrorPolicy.all,
        ));

        if (!upcomingResult.hasException && upcomingResult.data != null) {
          if (upcomingResult.data!['launchesUpcoming'] != null) {
            final List<dynamic> upcomingJson = upcomingResult.data!['launchesUpcoming'];
            final List<Launch> upcomingLaunches = upcomingJson
                .map((json) => Launch.fromJson(json))
                .toList();
            allLaunches.addAll(upcomingLaunches.map(_mapToEntity));
          }
        }
      }
      
      // Get paginated past launches
      final pastResult = await _client.query(QueryOptions(
        document: gql(paginatedLaunchesQuery),
        variables: {
          'limit': limit,
          'offset': offset,
        },
        fetchPolicy: FetchPolicy.networkOnly, // Always fetch fresh data
        errorPolicy: ErrorPolicy.all,
      ));

      if (pastResult.hasException) {
        // Try to return cached data as fallback
        final cachedLaunches = await _cacheManager.getCachedLaunches();
        if (cachedLaunches != null) {
          final endIndex = (offset + limit).clamp(0, cachedLaunches.length);
          final startIndex = offset.clamp(0, cachedLaunches.length);
          
          if (startIndex >= cachedLaunches.length) {
            return [];
          }
          
          return cachedLaunches.sublist(startIndex, endIndex);
        }
        throw _handleGraphQLException(pastResult.exception!);
      }

      if (pastResult.data != null && pastResult.data!['launchesPast'] != null) {
        final List<dynamic> pastJson = pastResult.data!['launchesPast'];
        final List<Launch> pastLaunches = pastJson
            .map((json) => Launch.fromJson(json))
            .toList();
        allLaunches.addAll(pastLaunches.map(_mapToEntity));
      }
      
      // Cache the launches data for offline use (only for first page)
      if (offset == 0 && allLaunches.isNotEmpty) {
        final launchesJson = allLaunches.map((launch) => _mapToJson(launch)).toList();
        await _cacheManager.cacheLaunchesJson(launchesJson);
      }
      
      return allLaunches;
    } catch (e) {
      // Try to return cached data as fallback
      final cachedLaunches = await _cacheManager.getCachedLaunches();
      if (cachedLaunches != null) {
        final endIndex = (offset + limit).clamp(0, cachedLaunches.length);
        final startIndex = offset.clamp(0, cachedLaunches.length);
        
        if (startIndex >= cachedLaunches.length) {
          return [];
        }
        
        return cachedLaunches.sublist(startIndex, endIndex);
      }
      
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to fetch launches: ${e.toString()}');
    }
  }

  @override
  Future<List<LaunchEntity>> getUpcomingLaunches() async {
    // Check if we have internet connectivity
    final hasConnection = await _connectivityManager.checkConnectivity();
    
    // Try to get cached data first if offline
    if (!hasConnection) {
      final cachedLaunches = await _cacheManager.getCachedUpcomingLaunches();
      if (cachedLaunches != null) {
        return cachedLaunches;
      }
      throw app_exceptions.NetworkException('No internet connection and no cached data available');
    }

    try {
      final QueryOptions options = QueryOptions(
        document: gql(upcomingLaunchesQuery),
        variables: {
          'limit': 50,
        },
        fetchPolicy: FetchPolicy.networkOnly, // Always fetch fresh data
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        // Try to return cached data as fallback
        final cachedLaunches = await _cacheManager.getCachedUpcomingLaunches();
        if (cachedLaunches != null) {
          return cachedLaunches;
        }
        throw _handleGraphQLException(result.exception!);
      }

      if (result.data == null || result.data!['launchesUpcoming'] == null) {
        // Try to return cached data as fallback
        final cachedLaunches = await _cacheManager.getCachedUpcomingLaunches();
        if (cachedLaunches != null) {
          return cachedLaunches;
        }
        return [];
      }

      final List<dynamic> launchesJson = result.data!['launchesUpcoming'];
      final List<Launch> launches = launchesJson
          .map((json) => Launch.fromJson(json))
          .toList();

      final upcomingLaunches = launches.map(_mapToEntity).toList();
      
      // Cache the upcoming launches data for offline use
      final upcomingJson = upcomingLaunches.map((launch) => _mapToJson(launch)).toList();
      await _cacheManager.cacheUpcomingLaunchesJson(upcomingJson);

      return upcomingLaunches;
    } catch (e) {
      // Try to return cached data as fallback
      final cachedLaunches = await _cacheManager.getCachedUpcomingLaunches();
      if (cachedLaunches != null) {
        return cachedLaunches;
      }
      
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to fetch upcoming launches: ${e.toString()}');
    }
  }

  @override
  Future<List<LaunchEntity>> getPastLaunches({int limit = 50}) async {
    // Check if we have internet connectivity
    final hasConnection = await _connectivityManager.checkConnectivity();
    
    // Try to get cached data first if offline
    if (!hasConnection) {
      final cachedLaunches = await _cacheManager.getCachedPastLaunches();
      if (cachedLaunches != null) {
        return cachedLaunches.take(limit).toList();
      }
      throw app_exceptions.NetworkException('No internet connection and no cached data available');
    }

    try {
      final QueryOptions options = QueryOptions(
        document: gql(pastLaunchesQuery),
        variables: {
          'limit': limit,
        },
        fetchPolicy: FetchPolicy.networkOnly, // Always fetch fresh data
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        // Try to return cached data as fallback
        final cachedLaunches = await _cacheManager.getCachedPastLaunches();
        if (cachedLaunches != null) {
          return cachedLaunches.take(limit).toList();
        }
        throw _handleGraphQLException(result.exception!);
      }

      if (result.data == null || result.data!['launchesPast'] == null) {
        // Try to return cached data as fallback
        final cachedLaunches = await _cacheManager.getCachedPastLaunches();
        if (cachedLaunches != null) {
          return cachedLaunches.take(limit).toList();
        }
        return [];
      }

      final List<dynamic> launchesJson = result.data!['launchesPast'];
      final List<Launch> launches = launchesJson
          .map((json) => Launch.fromJson(json))
          .toList();

      final pastLaunches = launches.map(_mapToEntity).toList();
      
      // Cache the past launches data for offline use
      final pastJson = pastLaunches.map((launch) => _mapToJson(launch)).toList();
      await _cacheManager.cachePastLaunchesJson(pastJson);

      return pastLaunches;
    } catch (e) {
      // Try to return cached data as fallback
      final cachedLaunches = await _cacheManager.getCachedPastLaunches();
      if (cachedLaunches != null) {
        return cachedLaunches.take(limit).toList();
      }
      
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to fetch past launches: ${e.toString()}');
    }
  }

  @override
  Future<List<LaunchEntity>> searchLaunches({
    required String searchTerm,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(launchesQuery),
        variables: {
          'searchTerm': searchTerm,
          'limit': limit,
          'offset': offset,
        },
        fetchPolicy: FetchPolicy.networkOnly,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        throw _handleGraphQLException(result.exception!);
      }

      if (result.data == null || result.data!['launches'] == null) {
        return [];
      }

      final List<dynamic> launchesJson = result.data!['launches'];
      final List<Launch> launches = launchesJson
          .map((json) => Launch.fromJson(json))
          .toList();

      return launches.map(_mapToEntity).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to search launches: ${e.toString()}');
    }
  }

  @override
  Future<List<LaunchEntity>> getLaunchesBySuccess({
    bool? success,
    int limit = 50,
  }) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(launchesQuery),
        variables: {
          'success': success,
          'limit': limit,
        },
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        throw _handleGraphQLException(result.exception!);
      }

      if (result.data == null || result.data!['launches'] == null) {
        return [];
      }

      final List<dynamic> launchesJson = result.data!['launches'];
      final List<Launch> launches = launchesJson
          .map((json) => Launch.fromJson(json))
          .toList();

      return launches.map(_mapToEntity).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to fetch launches by success: ${e.toString()}');
    }
  }

  @override
  Future<List<LaunchEntity>> getLaunchesByDateRange({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(launchesQuery),
        variables: {
          'startDate': startDate,
          'endDate': endDate,
        },
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        throw _handleGraphQLException(result.exception!);
      }

      if (result.data == null || result.data!['launches'] == null) {
        return [];
      }

      final List<dynamic> launchesJson = result.data!['launches'];
      final List<Launch> launches = launchesJson
          .map((json) => Launch.fromJson(json))
          .toList();

      return launches.map(_mapToEntity).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to fetch launches by date range: ${e.toString()}');
    }
  }

  @override
  Future<LaunchEntity> getLaunchByFlightNumber(int flightNumber) async {
    try {
      // Since flight_number field doesn't exist in API, use pagination to get launches
      // This is a workaround - ideally the interface should be updated
      final launches = await getLaunchesWithPagination(limit: 100, offset: 0);
      
      // Try to find launch by index (flightNumber as approximate index)
      if (flightNumber > 0 && flightNumber <= launches.length) {
        return launches[flightNumber - 1];
      }
      
      throw app_exceptions.ServerException('Launch with flight number $flightNumber not found');
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to fetch launch by flight number: ${e.toString()}');
    }
  }

  @override
  Future<List<LaunchEntity>> refreshLaunches() async {
    try {
      // Clear cache before fetching fresh data
      GraphQLService.clearCache();

      final QueryOptions options = QueryOptions(
        document: gql(launchesQuery),
        fetchPolicy: FetchPolicy.networkOnly,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        throw _handleGraphQLException(result.exception!);
      }

      if (result.data == null || result.data!['launches'] == null) {
        return [];
      }

      final List<dynamic> launchesJson = result.data!['launches'];
      final List<Launch> launches = launchesJson
          .map((json) => Launch.fromJson(json))
          .toList();

      return launches.map(_mapToEntity).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to refresh launches: ${e.toString()}');
    }
  }

  // Maps Launch data model to LaunchEntity domain entity
  LaunchEntity _mapToEntity(Launch launch) {
    return LaunchEntity(
      flightNumber: launch.flightNumber,
      missionName: launch.missionName,
      dateUtc: launch.launchDateUnix > 0 
          ? DateTime.fromMillisecondsSinceEpoch(launch.launchDateUnix * 1000)
          : null,
      success: launch.launchSuccess,
      upcoming: launch.upcoming,
      details: launch.details,
      links: LaunchLinksEntity(
        missionPatch: launch.links.missionPatch,
        missionPatchSmall: launch.links.missionPatchSmall,
        article: launch.links.articleLink,
        wikipedia: launch.links.wikipedia,
        videoLink: launch.links.videoLink,
        flickrImages: launch.links.flickrImages,
      ),
      rocket: launch.rocket.rocketName.isNotEmpty 
          ? LaunchRocketEntity(
              id: launch.rocket.rocketId,
              name: launch.rocket.rocketName,
              type: launch.rocket.rocketType,
              coreSerial: null, // Not available in simplified GraphQL
              coreReuse: null, // Not available in simplified GraphQL
              landingSuccess: null, // Not available in simplified GraphQL
            )
          : null,
      launchSite: launch.launchSite != null 
          ? LaunchSiteEntity(
              id: launch.launchSite!.siteId,
              name: launch.launchSite!.siteName,
              nameShort: launch.launchSite!.siteName, // Use siteName as short name
            )
          : null,
    );
  }

  // Maps LaunchEntity domain entity back to JSON for caching
  Map<String, dynamic> _mapToJson(LaunchEntity launch) {
    return {
      'flight_number': launch.flightNumber,
      'mission_name': launch.missionName,
      'launch_date_unix': launch.dateUtc?.millisecondsSinceEpoch != null 
          ? (launch.dateUtc!.millisecondsSinceEpoch / 1000).round()
          : 0,
      'launch_success': launch.success,
      'upcoming': launch.upcoming,
      'details': launch.details,
      'links': {
        'mission_patch': launch.links?.missionPatch,
        'mission_patch_small': launch.links?.missionPatchSmall,
        'article_link': launch.links?.article,
        'wikipedia': launch.links?.wikipedia,
        'video_link': launch.links?.videoLink,
        'flickr_images': launch.links?.flickrImages ?? [],
      },
      'rocket': launch.rocket != null ? {
        'rocket_id': launch.rocket!.id,
        'rocket_name': launch.rocket!.name,
        'rocket_type': launch.rocket!.type,
      } : null,
      'launch_site': launch.launchSite != null ? {
        'site_id': launch.launchSite!.id,
        'site_name': launch.launchSite!.name,
      } : null,
    };
  }

  // Handles GraphQL exceptions and converts them to appropriate app exceptions
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
}