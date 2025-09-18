import 'package:graphql_flutter/graphql_flutter.dart';

import '../../core/network/graphql_client.dart';
import '../../domain/entities/landpad_entity.dart';
import '../../domain/repositories/landpad_repository.dart';
import '../models/landpad_model.dart';
import '../queries/launches_query.dart';
import '../../core/utils/exceptions.dart' as app_exceptions;

/// Implementation of LandpadRepository using GraphQL
class LandpadRepositoryImpl implements LandpadRepository {
  final GraphQLClient _client;

  LandpadRepositoryImpl({GraphQLClient? client})
      : _client = client ?? GraphQLService.client;

  @override
  Future<List<LandpadEntity>> getLandpads({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final result = await _client.query(QueryOptions(
        document: gql(landpadsQuery),
        variables: {
          'limit': limit,
          'offset': offset,
        },
        fetchPolicy: FetchPolicy.cacheAndNetwork,
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
}
