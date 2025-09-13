import 'package:graphql_flutter/graphql_flutter.dart';

import '../../core/network/graphql_client.dart';
import '../../domain/entities/mission_entity.dart';
import '../../domain/repositories/mission_repository.dart';
import '../models/mission_model.dart';
import '../queries/mission_queries.dart';
import '../../core/utils/exceptions.dart' as app_exceptions;

/// Implementation of MissionRepository using GraphQL
///
/// This class handles all mission-related data operations using the SpaceX GraphQL API.
/// It includes comprehensive error handling and data transformation between
/// data models and domain entities.
class MissionRepositoryImpl implements MissionRepository {
  final GraphQLClient _client;

  MissionRepositoryImpl({GraphQLClient? client})
      : _client = client ?? GraphQLService.client;

  @override
  Future<List<MissionEntity>> getAllMissions() async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(MissionQueries.getAllMissions),
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        throw _handleGraphQLException(result.exception!);
      }

      if (result.data == null || result.data!['missions'] == null) {
        throw app_exceptions.ServerException('No mission data received from server');
      }

      final List<dynamic> missionsJson = result.data!['missions'];
      final List<Mission> missions = missionsJson
          .map((json) => Mission.fromJson(json))
          .toList();

      return missions.map(_mapToEntity).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to fetch missions: ${e.toString()}');
    }
  }

  @override
  Future<MissionEntity> getMissionById(String id) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(MissionQueries.getMissionById),
        variables: {'id': id},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        throw _handleGraphQLException(result.exception!);
      }

      if (result.data == null || result.data!['mission'] == null) {
        throw app_exceptions.ServerException('Mission with ID $id not found');
      }

      final Mission mission = Mission.fromJson(result.data!['mission']);
      return _mapToEntity(mission);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to fetch mission by ID: ${e.toString()}');
    }
  }

  @override
  Future<List<MissionEntity>> searchMissions(String searchTerm) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(MissionQueries.searchMissions),
        variables: {'searchTerm': searchTerm},
        fetchPolicy: FetchPolicy.networkOnly,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        throw _handleGraphQLException(result.exception!);
      }

      if (result.data == null || result.data!['missions'] == null) {
        return []; // Return empty list for no results
      }

      final List<dynamic> missionsJson = result.data!['missions'];
      final List<Mission> missions = missionsJson
          .map((json) => Mission.fromJson(json))
          .toList();

      return missions.map(_mapToEntity).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to search missions: ${e.toString()}');
    }
  }

  @override
  Future<List<MissionEntity>> getMissionsWithPagination({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(MissionQueries.getMissionsWithPagination),
        variables: {
          'limit': limit,
          'offset': offset,
        },
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        throw _handleGraphQLException(result.exception!);
      }

      if (result.data == null || result.data!['missions'] == null) {
        return [];
      }

      final List<dynamic> missionsJson = result.data!['missions'];
      final List<Mission> missions = missionsJson
          .map((json) => Mission.fromJson(json))
          .toList();

      return missions.map(_mapToEntity).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to fetch paginated missions: ${e.toString()}');
    }
  }

  @override
  Future<List<MissionEntity>> getMissionsByManufacturers(
      List<String> manufacturers,
      ) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(MissionQueries.getMissionsByManufacturers),
        variables: {'manufacturers': manufacturers},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        throw _handleGraphQLException(result.exception!);
      }

      if (result.data == null || result.data!['missions'] == null) {
        return [];
      }

      final List<dynamic> missionsJson = result.data!['missions'];
      final List<Mission> missions = missionsJson
          .map((json) => Mission.fromJson(json))
          .toList();

      return missions.map(_mapToEntity).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to fetch missions by manufacturers: ${e.toString()}');
    }
  }

  @override
  Future<List<MissionEntity>> refreshMissions() async {
    try {
      // Clear cache before fetching fresh data
      GraphQLService.clearCache();

      final QueryOptions options = QueryOptions(
        document: gql(MissionQueries.getAllMissions),
        fetchPolicy: FetchPolicy.networkOnly, // Force network fetch
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        throw _handleGraphQLException(result.exception!);
      }

      if (result.data == null || result.data!['missions'] == null) {
        throw app_exceptions.ServerException('No mission data received from server');
      }

      final List<dynamic> missionsJson = result.data!['missions'];
      final List<Mission> missions = missionsJson
          .map((json) => Mission.fromJson(json))
          .toList();

      return missions.map(_mapToEntity).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to refresh missions: ${e.toString()}');
    }
  }

  /// Maps Mission data model to MissionEntity domain entity
  MissionEntity _mapToEntity(Mission mission) {
    return MissionEntity(
      id: mission.id,
      name: mission.name,
      description: mission.description,
      manufacturers: mission.manufacturers,
      wikipedia: mission.wikipedia,
      website: mission.website,
      twitter: mission.twitter,
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