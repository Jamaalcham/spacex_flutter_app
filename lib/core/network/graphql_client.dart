import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';

class GraphQLService {
  static const String _endpoint = 'https://spacex-production.up.railway.app/';

  static HttpLink _httpLink = HttpLink(
    _endpoint,
    defaultHeaders: {
      'Content-Type': 'application/json',
    },
  );

  static GraphQLClient _client = GraphQLClient(
    link: _httpLink,
    cache: GraphQLCache(store: InMemoryStore()),
    defaultPolicies: DefaultPolicies(
      query: Policies(
        fetch: FetchPolicy.cacheAndNetwork,
        error: ErrorPolicy.all,
      ),
    ),
  );

  static GraphQLClient get client => _client;

  static ValueNotifier<GraphQLClient> get clientNotifier =>
      ValueNotifier(_client);

  static void clearCache() {
    _client.cache.store.reset();
  }

  static void updateEndpoint(String newEndpoint) {
    _httpLink = HttpLink(
      newEndpoint,
      defaultHeaders: {
        'Content-Type': 'application/json',
      },
    );
    _client = GraphQLClient(
      link: _httpLink,
      cache: GraphQLCache(store: InMemoryStore()),
      defaultPolicies: DefaultPolicies(
        query: Policies(
          fetch: FetchPolicy.cacheAndNetwork,
          error: ErrorPolicy.all,
        ),
      ),
    );
  }
}
