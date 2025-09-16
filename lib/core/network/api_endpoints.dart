/// API Endpoints for SpaceX API v4
/// 
/// Contains all the endpoint constants for the SpaceX API
class ApiEndpoints {
  static const String baseUrl = 'https://api.spacexdata.com/v4/';
  
  // Launch endpoints
  static const String launches = 'launches';
  static const String launchesQuery = 'launches/query';
  static const String launchesLatest = 'launches/latest';
  static const String launchesNext = 'launches/next';
  static const String launchesUpcoming = 'launches/upcoming';
  static const String launchesPast = 'launches/past';
  
  // Rocket endpoints
  static const String rockets = 'rockets';
  static const String rocketsQuery = 'rockets/query';
  
  // Capsule endpoints
  static const String capsules = 'capsules';
  static const String capsulesQuery = 'capsules/query';
  
  // Crew endpoints
  static const String crew = 'crew';
  static const String crewQuery = 'crew/query';
  
  // Ship endpoints
  static const String ships = 'ships';
  static const String shipsQuery = 'ships/query';
  
  // Company endpoint
  static const String company = 'company';
  
  // Launchpad endpoints
  static const String launchpads = 'launchpads';
  static const String launchpadsQuery = 'launchpads/query';
  
  // Landpad endpoints
  static const String landpads = 'landpads';
  static const String landpadsQuery = 'landpads/query';
  
  // Payload endpoints
  static const String payloads = 'payloads';
  static const String payloadsQuery = 'payloads/query';
  
  // Core endpoints
  static const String cores = 'cores';
  static const String coresQuery = 'cores/query';
  
  // Dragon endpoints
  static const String dragons = 'dragons';
  static const String dragonsQuery = 'dragons/query';
  
  // Starlink endpoints
  static const String starlink = 'starlink';
  static const String starlinkQuery = 'starlink/query';
  
  // History endpoints
  static const String history = 'history';
  static const String historyQuery = 'history/query';
  
  // Roadster endpoint
  static const String roadster = 'roadster';
  
  /// Get endpoint with ID
  static String withId(String endpoint, String id) => '$endpoint/$id';
}
