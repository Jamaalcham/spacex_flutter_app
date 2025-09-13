/// GraphQL queries for SpaceX rockets
/// 
/// This class contains all GraphQL query strings for fetching rocket data
/// from the SpaceX API. Queries are structured to fetch comprehensive
/// rocket specifications and performance data.
class RocketQueries {
  /// Query to fetch all rockets with complete specifications
  /// 
  /// Returns: List of rockets with full technical details
  static const String getAllRockets = '''
    query GetRockets {
      rockets {
        id
        name
        type
        active
        cost_per_launch
        success_rate_pct
        first_flight
        country
        company
        height {
          meters
          feet
        }
        diameter {
          meters
          feet
        }
        mass {
          kg
          lb
        }
        description
      }
    }
  ''';

  /// Query to fetch a specific rocket by ID
  /// 
  /// Variables:
  /// - id: String! (required) - The rocket ID to fetch
  /// 
  /// Returns: Single rocket with complete specifications
  static const String getRocketById = '''
    query GetRocketById(\$id: ID!) {
      rocket(id: \$id) {
        id
        name
        type
        active
        cost_per_launch
        success_rate_pct
        first_flight
        country
        company
        height {
          meters
          feet
        }
        diameter {
          meters
          feet
        }
        mass {
          kg
          lb
        }
        description
      }
    }
  ''';

  /// Query to fetch only active rockets
  /// 
  /// Returns: List of currently active rockets
  static const String getActiveRockets = '''
    query GetActiveRockets {
      rockets(find: { active: true }) {
        id
        name
        type
        active
        cost_per_launch
        success_rate_pct
        first_flight
        country
        company
        height {
          meters
          feet
        }
        diameter {
          meters
          feet
        }
        mass {
          kg
          lb
        }
        description
      }
    }
  ''';

  /// Lightweight query for rocket gallery view
  /// 
  /// Optimized for grid/list display with essential information
  /// 
  /// Returns: List of rockets with display-focused data
  static const String getRocketGalleryItems = '''
    query GetRocketGalleryItems {
      rockets {
        id
        name
        type
        active
        cost_per_launch
        success_rate_pct
        first_flight
        company
        height {
          meters
        }
        mass {
          kg
        }
        description
      }
    }
  ''';

  /// Query to fetch rockets with specifications only
  /// 
  /// Used for technical comparison views
  /// 
  /// Returns: List of rockets with technical specifications
  static const String getRocketSpecifications = '''
    query GetRocketSpecifications {
      rockets {
        id
        name
        type
        active
        cost_per_launch
        success_rate_pct
        height {
          meters
          feet
        }
        diameter {
          meters
          feet
        }
        mass {
          kg
          lb
        }
        description
      }
    }
  ''';

  /// Query to search rockets by name or type
  /// 
  /// Variables:
  /// - searchTerm: String! (required) - The search term to match
  /// 
  /// Returns: List of rockets matching the search criteria
  static const String searchRockets = '''
    query SearchRockets(\$searchTerm: String!) {
      rockets(find: { 
        \$or: [
          { name: { \$regex: \$searchTerm, \$options: "i" } },
          { type: { \$regex: \$searchTerm, \$options: "i" } }
        ]
      }) {
        id
        name
        type
        active
        cost_per_launch
        success_rate_pct
        first_flight
        company
        height {
          meters
        }
        mass {
          kg
        }
        description
      }
    }
  ''';

  /// Query to fetch rockets by company
  /// 
  /// Variables:
  /// - company: String! (required) - The company name to filter by
  /// 
  /// Returns: List of rockets from the specified company
  static const String getRocketsByCompany = '''
    query GetRocketsByCompany(\$company: String!) {
      rockets(find: { company: \$company }) {
        id
        name
        type
        active
        cost_per_launch
        success_rate_pct
        first_flight
        country
        company
        height {
          meters
          feet
        }
        diameter {
          meters
          feet
        }
        mass {
          kg
          lb
        }
        description
      }
    }
  ''';

  /// Query to fetch rockets with images only
  /// 
  /// Used for image gallery features
  /// 
  /// Returns: List of rockets that have Flickr images available
  static const String getRocketsWithImages = '''
    query GetRocketsWithImages {
      rockets {
        id
        name
        type
        active
        description
      }
    }
  ''';

  /// Query to get rocket statistics
  /// 
  /// Returns: Aggregated statistics about rockets
  static const String getRocketStats = '''
    query GetRocketStats {
      rockets {
        id
        active
        success_rate_pct
        cost_per_launch
        first_flight
      }
    }
  ''';
}
