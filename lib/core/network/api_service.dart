import 'package:dio/dio.dart';
import 'rest_client.dart';
import 'network_exceptions.dart';
import 'api_endpoints.dart';

// API Service for SpaceX data

class ApiService {
  static ApiService? _instance;
  final RestClient _restClient;

  ApiService._internal() : _restClient = RestClient.instance;

  // Singleton instance
  static ApiService get instance {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  // Generic method to handle API calls with error handling
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
}
