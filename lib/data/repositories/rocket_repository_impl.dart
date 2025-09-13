import 'package:graphql_flutter/graphql_flutter.dart';

import '../../core/network/graphql_client.dart';
import '../../domain/entities/rocket_entity.dart';
import '../../domain/repositories/rocket_repository.dart';
import '../models/rocket_model.dart';
import '../queries/rocket_queries.dart';
import '../../core/utils/exceptions.dart' as app_exceptions;

/// Implementation of RocketRepository using GraphQL
///
/// This class handles all rocket-related data operations using the SpaceX GraphQL API.
/// It includes comprehensive error handling and data transformation between
/// data models and domain entities.
class RocketRepositoryImpl implements RocketRepository {
  final GraphQLClient _client;

  RocketRepositoryImpl({GraphQLClient? client})
      : _client = client ?? GraphQLService.client;

  @override
  Future<List<RocketEntity>> getAllRockets() async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(RocketQueries.getAllRockets),
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        throw _handleGraphQLException(result.exception!);
      }

      if (result.data == null || result.data!['rockets'] == null) {
        throw app_exceptions.ServerException('No rocket data received from server');
      }

      final List<dynamic> rocketsJson = result.data!['rockets'];
      final List<Rocket> rockets = rocketsJson
          .map((json) => Rocket.fromJson(json))
          .toList();

      return rockets.map(_mapToEntity).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to fetch rockets: ${e.toString()}');
    }
  }

  @override
  Future<RocketEntity> getRocketById(String id) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(RocketQueries.getRocketById),
        variables: {'id': id},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        throw _handleGraphQLException(result.exception!);
      }

      if (result.data == null || result.data!['rocket'] == null) {
        throw app_exceptions.ServerException('Rocket with ID $id not found');
      }

      final Rocket rocket = Rocket.fromJson(result.data!['rocket']);
      return _mapToEntity(rocket);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to fetch rocket by ID: ${e.toString()}');
    }
  }

  @override
  Future<List<RocketEntity>> getActiveRockets() async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(RocketQueries.getActiveRockets),
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        throw _handleGraphQLException(result.exception!);
      }

      if (result.data == null || result.data!['rockets'] == null) {
        return [];
      }

      final List<dynamic> rocketsJson = result.data!['rockets'];
      final List<Rocket> rockets = rocketsJson
          .map((json) => Rocket.fromJson(json))
          .toList();

      return rockets.map(_mapToEntity).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to fetch active rockets: ${e.toString()}');
    }
  }

  @override
  Future<List<RocketEntity>> searchRockets(String searchTerm) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(RocketQueries.searchRockets),
        variables: {'searchTerm': searchTerm},
        fetchPolicy: FetchPolicy.networkOnly,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        throw _handleGraphQLException(result.exception!);
      }

      if (result.data == null || result.data!['rockets'] == null) {
        return [];
      }

      final List<dynamic> rocketsJson = result.data!['rockets'];
      final List<Rocket> rockets = rocketsJson
          .map((json) => Rocket.fromJson(json))
          .toList();

      return rockets.map(_mapToEntity).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to search rockets: ${e.toString()}');
    }
  }

  @override
  Future<List<RocketEntity>> getRocketsByCompany(String company) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(RocketQueries.getRocketsByCompany),
        variables: {'company': company},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        throw _handleGraphQLException(result.exception!);
      }

      if (result.data == null || result.data!['rockets'] == null) {
        return [];
      }

      final List<dynamic> rocketsJson = result.data!['rockets'];
      final List<Rocket> rockets = rocketsJson
          .map((json) => Rocket.fromJson(json))
          .toList();

      return rockets.map(_mapToEntity).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to fetch rockets by company: ${e.toString()}');
    }
  }

  @override
  Future<List<RocketEntity>> getRocketsWithImages() async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(RocketQueries.getRocketsWithImages),
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        throw _handleGraphQLException(result.exception!);
      }

      if (result.data == null || result.data!['rockets'] == null) {
        return [];
      }

      final List<dynamic> rocketsJson = result.data!['rockets'];
      final List<Rocket> rockets = rocketsJson
          .map((json) => Rocket.fromJson(json))
          .toList();

      return rockets.map(_mapToEntity).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to fetch rockets with images: ${e.toString()}');
    }
  }

  @override
  Future<List<RocketEntity>> refreshRockets() async {
    try {
      // Clear cache before fetching fresh data
      GraphQLService.clearCache();

      final QueryOptions options = QueryOptions(
        document: gql(RocketQueries.getAllRockets),
        fetchPolicy: FetchPolicy.networkOnly,
        errorPolicy: ErrorPolicy.all,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        throw _handleGraphQLException(result.exception!);
      }

      if (result.data == null || result.data!['rockets'] == null) {
        throw app_exceptions.ServerException('No rocket data received from server');
      }

      final List<dynamic> rocketsJson = result.data!['rockets'];
      final List<Rocket> rockets = rocketsJson
          .map((json) => Rocket.fromJson(json))
          .toList();

      return rockets.map(_mapToEntity).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Failed to refresh rockets: ${e.toString()}');
    }
  }

  /// Maps Rocket data model to RocketEntity domain entity
  RocketEntity _mapToEntity(Rocket rocket) {
    return RocketEntity(
      id: rocket.id,
      name: rocket.name,
      type: rocket.type,
      active: rocket.active,
      costPerLaunch: rocket.costPerLaunch,
      successRatePct: rocket.successRatePct,
      firstFlight: rocket.firstFlight,
      country: rocket.country,
      company: rocket.company,
      height: rocket.height != null ? DimensionsEntity(
        meters: rocket.height!.meters,
        feet: rocket.height!.feet,
      ) : null,
      diameter: rocket.diameter != null ? DimensionsEntity(
        meters: rocket.diameter!.meters,
        feet: rocket.diameter!.feet,
      ) : null,
      mass: rocket.mass != null ? MassEntity(
        kg: rocket.mass!.kg,
        lb: rocket.mass!.lb,
      ) : null,
      description: rocket.description,
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