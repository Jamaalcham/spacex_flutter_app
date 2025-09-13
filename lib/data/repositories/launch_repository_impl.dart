import 'package:graphql_flutter/graphql_flutter.dart';

import '../../core/network/graphql_client.dart';
import '../../domain/entities/launch_entity.dart';
import '../../domain/repositories/launch_repository.dart';
import '../models/launch_model.dart';
import '../queries/launch_queries.dart';
import '../../core/utils/exceptions.dart' as app_exceptions;

/// Implementation of LaunchRepository using GraphQL
///
/// This class handles all launch-related data operations using the SpaceX GraphQL API.
/// It includes comprehensive error handling and data transformation between
/// data models and domain entities.
class LaunchRepositoryImpl implements LaunchRepository {
  final GraphQLClient _client;

  LaunchRepositoryImpl({GraphQLClient? client})
      : _client = client ?? GraphQLService.client;

  @override
  Future<List<LaunchEntity>> getLaunchesWithPagination({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final result = await _client.query(QueryOptions(
        document: gql(LaunchQueries.getLaunchesWithPagination),
        variables: {
          'limit': limit,
          'offset': offset,
          'order': 'desc', // Most recent first
        },
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        errorPolicy: ErrorPolicy.all,
      ));

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
      throw app_exceptions.ServerException('Failed to fetch launches: ${e.toString()}');
    }
  }

  @override
  Future<List<LaunchEntity>> getUpcomingLaunches() async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(LaunchQueries.getUpcomingLaunches),
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        throw _handleGraphQLException(result.exception!);
      }

      if (result.data == null || result.data!['launchesUpcoming'] == null) {
        return [];
      }

      final List<dynamic> launchesJson = result.data!['launchesUpcoming'];
      final List<Launch> launches = launchesJson
          .map((json) => Launch.fromJson(json))
          .toList();

      return launches.map(_mapToEntity).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to fetch upcoming launches: ${e.toString()}');
    }
  }

  @override
  Future<List<LaunchEntity>> getPastLaunches({int limit = 50}) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(LaunchQueries.getPastLaunches),
        variables: {'limit': limit},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        throw _handleGraphQLException(result.exception!);
      }

      if (result.data == null || result.data!['launchesPast'] == null) {
        return [];
      }

      final List<dynamic> launchesJson = result.data!['launchesPast'];
      final List<Launch> launches = launchesJson
          .map((json) => Launch.fromJson(json))
          .toList();

      return launches.map(_mapToEntity).toList();
    } catch (e) {
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
        document: gql(LaunchQueries.searchLaunches),
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
        document: gql(LaunchQueries.getAllLaunches),
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
        document: gql(LaunchQueries.getAllLaunches),
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
      final QueryOptions options = QueryOptions(
        document: gql(LaunchQueries.getLaunchByFlightNumber),
        variables: {'flightNumber': flightNumber},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        throw _handleGraphQLException(result.exception!);
      }

      if (result.data == null || result.data!['launch'] == null) {
        throw app_exceptions.ServerException('Launch with flight number $flightNumber not found');
      }

      final Launch launch = Launch.fromJson(result.data!['launch']);
      return _mapToEntity(launch);
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
        document: gql(LaunchQueries.getAllLaunches),
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

  /// Maps Launch data model to LaunchEntity domain entity
  LaunchEntity _mapToEntity(Launch launch) {
    return LaunchEntity(
      flightNumber: launch.flightNumber,
      missionName: launch.missionName,
      dateUtc: DateTime.fromMillisecondsSinceEpoch(launch.launchDateUnix * 1000),
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
      rocket: LaunchRocketEntity(
        id: launch.rocket.rocketId,
        name: launch.rocket.rocketName,
        type: launch.rocket.rocketType,
        coreSerial: null, // Not available in current model
        coreReuse: null, // Not available in current model
        landingSuccess: null, // Not available in current model
      ),
      launchSite: LaunchSiteEntity(
        id: launch.launchSite.siteId,
        name: launch.launchSite.siteName,
        nameShort: launch.launchSite.siteName, // Use siteName as short name
      ),
    );
  }

  /// Handles GraphQL exceptions and converts them to appropriate app exceptions
  app_exceptions.AppException _handleGraphQLException(OperationException exception) {
    if (exception.linkException != null) {
      final linkException = exception.linkException!;

      if (linkException is NetworkException) {
        return app_exceptions.NetworkException('Network error: Please check your internet connection');
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