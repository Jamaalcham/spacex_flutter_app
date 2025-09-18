import 'package:graphql_flutter/graphql_flutter.dart';

import '../../core/network/graphql_client.dart';
import '../../domain/entities/launch_entity.dart';
import '../../domain/entities/launchpad_entity.dart';
import '../../domain/entities/landpad_entity.dart';
import '../../domain/repositories/launch_repository.dart';
import '../models/launchpad_model.dart';
import '../models/landpad_model.dart';
import '../queries/launches_query.dart';
import '../../core/utils/exceptions.dart' as app_exceptions;

// Implementation of LaunchRepository using GraphQL for the combined launches query
class LaunchesRepositoryImpl implements LaunchRepository {
  final GraphQLClient _client;

  LaunchesRepositoryImpl({GraphQLClient? client})
      : _client = client ?? GraphQLService.client;

  @override
  Future<List<LaunchEntity>> getUpcomingLaunches() async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(launchesQuery),
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
      return launchesJson.map((json) => _mapUpcomingLaunchToEntity(json)).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to fetch upcoming launches: ${e.toString()}');
    }
  }

  @override
  Future<List<LaunchEntity>> getPastLaunches({int limit = 50}) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(launchesQuery),
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
      return launchesJson.map((json) => _mapPastLaunchToEntity(json)).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to fetch past launches: ${e.toString()}');
    }
  }

  Future<List<LaunchpadEntity>> getLaunchpads() async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(launchesQuery),
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        throw _handleGraphQLException(result.exception!);
      }

      if (result.data == null || result.data!['launchpads'] == null) {
        return [];
      }

      final List<dynamic> launchpadsJson = result.data!['launchpads'];
      return launchpadsJson.map((json) => LaunchpadModel.fromJson(json)).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to fetch launchpads: ${e.toString()}');
    }
  }

  Future<List<LandpadEntity>> getLandpads() async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(launchesQuery),
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        throw _handleGraphQLException(result.exception!);
      }

      if (result.data == null || result.data!['landpads'] == null) {
        return [];
      }

      final List<dynamic> landpadsJson = result.data!['landpads'];
      return landpadsJson.map((json) => LandpadModel.fromJson(json)).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to fetch landpads: ${e.toString()}');
    }
  }

  // Required interface methods with basic implementations
  @override
  Future<List<LaunchEntity>> getLaunchesWithPagination({int limit = 20, int offset = 0}) async {
    final upcoming = await getUpcomingLaunches();
    final past = await getPastLaunches(limit: limit);
    return [...upcoming, ...past];
  }

  @override
  Future<List<LaunchEntity>> searchLaunches({required String searchTerm, int limit = 20, int offset = 0}) async {
    final all = await getLaunchesWithPagination(limit: limit, offset: offset);
    return all.where((launch) => 
      launch.missionName.toLowerCase().contains(searchTerm.toLowerCase()) ||
      launch.rocket!.name.toLowerCase().contains(searchTerm.toLowerCase())
    ).toList();
  }

  @override
  Future<List<LaunchEntity>> getLaunchesBySuccess({bool? success, int limit = 50}) async {
    final all = await getLaunchesWithPagination(limit: limit);
    if (success == null) return all;
    return all.where((launch) => launch.success == success).toList();
  }

  @override
  Future<List<LaunchEntity>> getLaunchesByDateRange({required String startDate, required String endDate}) async {
    final all = await getLaunchesWithPagination();
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    return all.where((launch) => 
      launch.dateUtc!.isAfter(start) && launch.dateUtc!.isBefore(end)
    ).toList();
  }

  @override
  Future<LaunchEntity> getLaunchByFlightNumber(int flightNumber) async {
    final launches = await getLaunchesWithPagination();
    if (flightNumber > 0 && flightNumber <= launches.length) {
      return launches[flightNumber - 1];
    }
    throw app_exceptions.ServerException('Launch with flight number $flightNumber not found');
  }

  @override
  Future<List<LaunchEntity>> refreshLaunches() async {
    GraphQLService.clearCache();
    return getLaunchesWithPagination();
  }

  /// Maps upcoming launch JSON to LaunchEntity
  LaunchEntity _mapUpcomingLaunchToEntity(Map<String, dynamic> json) {
    return LaunchEntity(
      flightNumber: 0, // Not available in upcoming launches
      missionName: json['mission_name']?.toString() ?? 'Unknown Mission',
      dateUtc: DateTime.parse(json['launch_date_utc'] ?? DateTime.now().toIso8601String()),
      success: json['launch_success'],
      upcoming: json['upcoming'] ?? true,
      details: json['details']?.toString(),
      links: LaunchLinksEntity(
        missionPatch: null,
        missionPatchSmall: null,
        article: null,
        wikipedia: null,
        videoLink: null,
        flickrImages: [],
      ),
      rocket: LaunchRocketEntity(
        id: json['rocket']?['rocket_id']?.toString() ?? '',
        name: json['rocket']?['rocket_name']?.toString() ?? 'Unknown Rocket',
        type: '',
        coreSerial: null,
        coreReuse: null,
        landingSuccess: null,
      ),
      launchSite: LaunchSiteEntity(
        id: json['launch_site']?['site_id']?.toString() ?? '',
        name: json['launch_site']?['site_name']?.toString() ?? 'Unknown Site',
        nameShort: json['launch_site']?['site_name']?.toString() ?? 'Unknown',
      ),
    );
  }

  /// Maps past launch JSON to LaunchEntity
  LaunchEntity _mapPastLaunchToEntity(Map<String, dynamic> json) {
    return LaunchEntity(
      flightNumber: 0, // Not available in past launches
      missionName: json['mission_name']?.toString() ?? 'Unknown Mission',
      dateUtc: DateTime.parse(json['launch_date_utc'] ?? DateTime.now().toIso8601String()),
      success: json['launch_success'],
      upcoming: json['upcoming'] ?? false,
      details: json['details']?.toString(),
      links: LaunchLinksEntity(
        missionPatch: null,
        missionPatchSmall: null,
        article: null,
        wikipedia: null,
        videoLink: null,
        flickrImages: [],
      ),
      rocket: LaunchRocketEntity(
        id: json['rocket']?['rocket_id']?.toString() ?? '',
        name: json['rocket']?['rocket_name']?.toString() ?? 'Unknown Rocket',
        type: '',
        coreSerial: null,
        coreReuse: null,
        landingSuccess: null,
      ),
      launchSite: LaunchSiteEntity(
        id: '',
        name: 'Unknown Site',
        nameShort: 'Unknown',
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
