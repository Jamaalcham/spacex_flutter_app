// API Endpoints for SpaceX API v4
class ApiEndpoints {
  static const String baseUrl = 'https://api.spacexdata.com/v4/';
  // Rocket endpoints
  static const String rockets = 'rockets';
  static const String rocketsQuery = 'rockets/query';
  
  // Capsule endpoints
  static const String capsules = 'capsules';
  static const String capsulesQuery = 'capsules/query';

  // Get endpoint with ID
  static String withId(String endpoint, String id) => '$endpoint/$id';
}
