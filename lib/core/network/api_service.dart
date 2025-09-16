import 'package:dio/dio.dart';
import 'rest_client.dart';
import 'network_exceptions.dart';
import 'api_endpoints.dart';

/// API Service for SpaceX data
/// 
/// Provides high-level methods to interact with the SpaceX API
class ApiService {
  static ApiService? _instance;
  final RestClient _restClient;

  ApiService._internal() : _restClient = RestClient.instance;

  /// Singleton instance
  static ApiService get instance {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  /// Generic method to handle API calls with error handling
  Future<T> _handleApiCall<T>(Future<Response<T>> Function() apiCall) async {
    try {
      final response = await apiCall();
      return response.data!;
    } on DioException catch (e) {
      throw NetworkExceptionHandler.handleDioError(e);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }

  // Launch methods
  Future<List<dynamic>> getLaunches({
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _handleApiCall(() => _restClient.get<List<dynamic>>(
      ApiEndpoints.launches,
      queryParameters: queryParameters,
    ));
  }

  Future<Map<String, dynamic>> getLatestLaunch() async {
    return await _handleApiCall(() => _restClient.get<Map<String, dynamic>>(
      ApiEndpoints.launchesLatest,
    ));
  }

  Future<Map<String, dynamic>> getNextLaunch() async {
    return await _handleApiCall(() => _restClient.get<Map<String, dynamic>>(
      ApiEndpoints.launchesNext,
    ));
  }

  Future<List<dynamic>> getUpcomingLaunches({
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _handleApiCall(() => _restClient.get<List<dynamic>>(
      ApiEndpoints.launchesUpcoming,
      queryParameters: queryParameters,
    ));
  }

  Future<List<dynamic>> getPastLaunches({
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _handleApiCall(() => _restClient.get<List<dynamic>>(
      ApiEndpoints.launchesPast,
      queryParameters: queryParameters,
    ));
  }

  Future<Map<String, dynamic>> getLaunchById(String id) async {
    return await _handleApiCall(() => _restClient.get<Map<String, dynamic>>(
      ApiEndpoints.withId(ApiEndpoints.launches, id),
    ));
  }

  Future<Map<String, dynamic>> queryLaunches({
    required Map<String, dynamic> query,
  }) async {
    return await _handleApiCall(() => _restClient.post<Map<String, dynamic>>(
      ApiEndpoints.launchesQuery,
      data: query,
    ));
  }

  // Rocket methods
  Future<List<dynamic>> getRockets({
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _handleApiCall(() => _restClient.get<List<dynamic>>(
      ApiEndpoints.rockets,
      queryParameters: queryParameters,
    ));
  }

  Future<Map<String, dynamic>> getRocketById(String id) async {
    return await _handleApiCall(() => _restClient.get<Map<String, dynamic>>(
      ApiEndpoints.withId(ApiEndpoints.rockets, id),
    ));
  }

  Future<Map<String, dynamic>> queryRockets({
    required Map<String, dynamic> query,
  }) async {
    return await _handleApiCall(() => _restClient.post<Map<String, dynamic>>(
      ApiEndpoints.rocketsQuery,
      data: query,
    ));
  }

  // Capsule methods
  Future<List<dynamic>> getCapsules({
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _handleApiCall(() => _restClient.get<List<dynamic>>(
      ApiEndpoints.capsules,
      queryParameters: queryParameters,
    ));
  }

  Future<Map<String, dynamic>> getCapsuleById(String id) async {
    return await _handleApiCall(() => _restClient.get<Map<String, dynamic>>(
      ApiEndpoints.withId(ApiEndpoints.capsules, id),
    ));
  }

  Future<Map<String, dynamic>> queryCapsules({
    required Map<String, dynamic> query,
  }) async {
    return await _handleApiCall(() => _restClient.post<Map<String, dynamic>>(
      ApiEndpoints.capsulesQuery,
      data: query,
    ));
  }

  // Crew methods
  Future<List<dynamic>> getCrew({
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _handleApiCall(() => _restClient.get<List<dynamic>>(
      ApiEndpoints.crew,
      queryParameters: queryParameters,
    ));
  }

  Future<Map<String, dynamic>> getCrewById(String id) async {
    return await _handleApiCall(() => _restClient.get<Map<String, dynamic>>(
      ApiEndpoints.withId(ApiEndpoints.crew, id),
    ));
  }

  // Ship methods
  Future<List<dynamic>> getShips({
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _handleApiCall(() => _restClient.get<List<dynamic>>(
      ApiEndpoints.ships,
      queryParameters: queryParameters,
    ));
  }

  Future<Map<String, dynamic>> getShipById(String id) async {
    return await _handleApiCall(() => _restClient.get<Map<String, dynamic>>(
      ApiEndpoints.withId(ApiEndpoints.ships, id),
    ));
  }

  // Company method
  Future<Map<String, dynamic>> getCompany() async {
    return await _handleApiCall(() => _restClient.get<Map<String, dynamic>>(
      ApiEndpoints.company,
    ));
  }

  // Launchpad methods
  Future<List<dynamic>> getLaunchpads({
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _handleApiCall(() => _restClient.get<List<dynamic>>(
      ApiEndpoints.launchpads,
      queryParameters: queryParameters,
    ));
  }

  Future<Map<String, dynamic>> getLaunchpadById(String id) async {
    return await _handleApiCall(() => _restClient.get<Map<String, dynamic>>(
      ApiEndpoints.withId(ApiEndpoints.launchpads, id),
    ));
  }

  // Landpad methods
  Future<List<dynamic>> getLandpads({
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _handleApiCall(() => _restClient.get<List<dynamic>>(
      ApiEndpoints.landpads,
      queryParameters: queryParameters,
    ));
  }

  Future<Map<String, dynamic>> getLandpadById(String id) async {
    return await _handleApiCall(() => _restClient.get<Map<String, dynamic>>(
      ApiEndpoints.withId(ApiEndpoints.landpads, id),
    ));
  }

  // Payload methods
  Future<List<dynamic>> getPayloads({
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _handleApiCall(() => _restClient.get<List<dynamic>>(
      ApiEndpoints.payloads,
      queryParameters: queryParameters,
    ));
  }

  Future<Map<String, dynamic>> getPayloadById(String id) async {
    return await _handleApiCall(() => _restClient.get<Map<String, dynamic>>(
      ApiEndpoints.withId(ApiEndpoints.payloads, id),
    ));
  }

  // Core methods
  Future<List<dynamic>> getCores({
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _handleApiCall(() => _restClient.get<List<dynamic>>(
      ApiEndpoints.cores,
      queryParameters: queryParameters,
    ));
  }

  Future<Map<String, dynamic>> getCoreById(String id) async {
    return await _handleApiCall(() => _restClient.get<Map<String, dynamic>>(
      ApiEndpoints.withId(ApiEndpoints.cores, id),
    ));
  }

  // Dragon methods
  Future<List<dynamic>> getDragons({
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _handleApiCall(() => _restClient.get<List<dynamic>>(
      ApiEndpoints.dragons,
      queryParameters: queryParameters,
    ));
  }

  Future<Map<String, dynamic>> getDragonById(String id) async {
    return await _handleApiCall(() => _restClient.get<Map<String, dynamic>>(
      ApiEndpoints.withId(ApiEndpoints.dragons, id),
    ));
  }

  // Starlink methods
  Future<List<dynamic>> getStarlink({
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _handleApiCall(() => _restClient.get<List<dynamic>>(
      ApiEndpoints.starlink,
      queryParameters: queryParameters,
    ));
  }

  // History methods
  Future<List<dynamic>> getHistory({
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _handleApiCall(() => _restClient.get<List<dynamic>>(
      ApiEndpoints.history,
      queryParameters: queryParameters,
    ));
  }

  Future<Map<String, dynamic>> getHistoryById(String id) async {
    return await _handleApiCall(() => _restClient.get<Map<String, dynamic>>(
      ApiEndpoints.withId(ApiEndpoints.history, id),
    ));
  }

  // Roadster method
  Future<Map<String, dynamic>> getRoadster() async {
    return await _handleApiCall(() => _restClient.get<Map<String, dynamic>>(
      ApiEndpoints.roadster,
    ));
  }
}
