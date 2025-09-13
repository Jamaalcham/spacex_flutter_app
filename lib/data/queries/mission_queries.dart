/// GraphQL queries for SpaceX missions
/// 
/// This class contains all GraphQL query strings for fetching mission data
/// from the SpaceX API. Each query is optimized to fetch only the necessary
/// fields to minimize bandwidth and improve performance.
class MissionQueries {
  /// Query to fetch all missions with essential information
  /// 
  /// Returns: List of missions with id, name, description, and manufacturers
  static const String getAllMissions = '''
    query GetAllMissions {
      missions {
        id
        name
        description
        manufacturers
        wikipedia
        website
        twitter
      }
    }
  ''';

  /// Query to fetch a specific mission by ID
  /// 
  /// Variables:
  /// - id: String! (required) - The mission ID to fetch
  /// 
  /// Returns: Single mission with complete details
  static const String getMissionById = '''
    query GetMissionById(\$id: ID!) {
      mission(id: \$id) {
        id
        name
        description
        manufacturers
        wikipedia
        website
        twitter
      }
    }
  ''';

  /// Query to fetch missions with pagination support
  /// 
  /// Variables:
  /// - limit: Int - Maximum number of missions to return (default: 10)
  /// - offset: Int - Number of missions to skip (default: 0)
  /// 
  /// Returns: Paginated list of missions
  static const String getMissionsWithPagination = '''
    query GetMissionsWithPagination(\$limit: Int, \$offset: Int) {
      missions(limit: \$limit, offset: \$offset) {
        id
        name
        description
        manufacturers
        wikipedia
        website
        twitter
      }
    }
  ''';

  /// Query to search missions by name
  /// 
  /// Variables:
  /// - searchTerm: String! (required) - The search term to match against mission names
  /// 
  /// Returns: List of missions matching the search criteria
  static const String searchMissions = '''
    query SearchMissions(\$searchTerm: String!) {
      missions(find: { name: \$searchTerm }) {
        id
        name
        description
        manufacturers
        wikipedia
        website
        twitter
      }
    }
  ''';

  /// Query to get mission count for pagination
  /// 
  /// Returns: Total number of missions available
  static const String getMissionCount = '''
    query GetMissionCount {
      missionsResult {
        totalCount
      }
    }
  ''';

  /// Query to fetch missions with specific manufacturers
  /// 
  /// Variables:
  /// - manufacturers: [String!]! (required) - Array of manufacturer names to filter by
  /// 
  /// Returns: List of missions from specified manufacturers
  static const String getMissionsByManufacturers = '''
    query GetMissionsByManufacturers(\$manufacturers: [String!]!) {
      missions(find: { manufacturers: { \$in: \$manufacturers } }) {
        id
        name
        description
        manufacturers
        wikipedia
        website
        twitter
      }
    }
  ''';

  /// Lightweight query for mission list items (minimal data)
  /// 
  /// Used for initial loading and list views where full details aren't needed
  /// 
  /// Returns: List of missions with only essential display information
  static const String getMissionListItems = '''
    query GetMissionListItems {
      missions {
        id
        name
        description
        manufacturers
      }
    }
  ''';

  /// Query to fetch missions with external links only
  /// 
  /// Useful for creating a "Learn More" section or external resources list
  /// 
  /// Returns: List of missions that have external links available
  static const String getMissionsWithLinks = '''
    query GetMissionsWithLinks {
      missions(find: { 
        \$or: [
          { wikipedia: { \$ne: null } },
          { website: { \$ne: null } },
          { twitter: { \$ne: null } }
        ]
      }) {
        id
        name
        description
        wikipedia
        website
        twitter
      }
    }
  ''';
}
