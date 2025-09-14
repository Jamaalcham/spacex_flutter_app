/// GraphQL queries for SpaceX launches
/// 
/// This class contains all GraphQL query strings for fetching launch data
/// from the SpaceX API. Queries support filtering by launch status,
/// date ranges, and mission types.
class LaunchQueries {
  /// Query to fetch all launches with complete information
  /// 
  /// Returns: List of launches with full details including rocket, site, and links
  static const String getAllLaunches = '''
    query GetAllLaunches {
      launches {
        mission_name
        mission_id
        launch_year
        launch_date_unix
        launch_date_utc
        launch_date_local
        is_tentative
        tentative_max_precision
        launch_success
        launch_failure_details {
          time
          altitude
          reason
        }
        upcoming
        details
        rocket {
          rocket_name
          rocket_type
        }
        launch_site {
          site_id
          site_name
          site_name_long
        }
        links {
          mission_patch
          mission_patch_small
          reddit_campaign
          reddit_launch
          reddit_recovery
          reddit_media
          presskit
          article_link
          wikipedia
          video_link
          youtube_id
          flickr_images
        }
        static_fire_date_utc
        static_fire_date_unix
        timeline
      }
    }
  ''';

  /// Query to fetch upcoming launches only
  /// 
  /// Returns: List of future launches sorted by launch date
  static const String getUpcomingLaunches = '''
    query GetUpcomingLaunches {
      launchesUpcoming {
        mission_name
        mission_id
        launch_year
        launch_date_unix
        launch_date_utc
        launch_date_local
        is_tentative
        tentative_max_precision
        upcoming
        details
        rocket {
          rocket_name
          rocket_type
        }
        launch_site {
          site_id
          site_name
          site_name_long
        }
        links {
          mission_patch
          mission_patch_small
          reddit_campaign
          reddit_launch
          presskit
          article_link
          wikipedia
          video_link
          youtube_id
          flickr_images
        }
        static_fire_date_utc
        static_fire_date_unix
      }
    }
  ''';

  /// Query to fetch past launches only
  /// 
  /// Returns: List of completed launches sorted by launch date (newest first)
  static const String getPastLaunches = '''
    query GetPastLaunches {
      launchesPast {
        mission_name
        mission_id
        launch_year
        launch_date_unix
        launch_date_utc
        launch_date_local
        launch_success
        launch_failure_details {
          time
          altitude
          reason
        }
        details
        rocket {
          rocket_name
          rocket_type
        }
        launch_site {
          site_id
          site_name
          site_name_long
        }
        links {
          mission_patch
          mission_patch_small
          reddit_campaign
          reddit_launch
          reddit_recovery
          reddit_media
          presskit
          article_link
          wikipedia
          video_link
          youtube_id
          flickr_images
        }
      }
    }
  ''';

  /// Query to fetch a specific launch by mission name
  /// 
  /// Variables:
  /// - mission_name: String! (required) - The mission name to fetch
  /// 
  /// Returns: Single launch with complete details
  static const String getLaunchByMissionName = '''
    query GetLaunchByMissionName(\$mission_name: String!) {
      launch(find: { mission_name: \$mission_name }) {
        mission_name
        mission_id
        launch_year
        launch_date_unix
        launch_date_utc
        launch_date_local
        is_tentative
        tentative_max_precision
        launch_success
        launch_failure_details {
          time
          altitude
          reason
        }
        upcoming
        details
        rocket {
          rocket_name
          rocket_type
        }
        launch_site {
          site_id
          site_name
          site_name_long
        }
        links {
          mission_patch
          mission_patch_small
          reddit_campaign
          reddit_launch
          reddit_recovery
          reddit_media
          presskit
          article_link
          wikipedia
          video_link
          youtube_id
          flickr_images
        }
        static_fire_date_utc
        static_fire_date_unix
        timeline
      }
    }
  ''';

  /// Query to fetch launches with pagination
  /// 
  /// Variables:
  /// - limit: Int - Maximum number of launches to return
  /// - offset: Int - Number of launches to skip
  /// - order: String - Sort order ("asc" or "desc")
  /// 
  /// Returns: Paginated list of launches
  static const String getLaunchesWithPagination = '''
    query GetLaunchesWithPagination(\$limit: Int, \$offset: Int, \$order: String) {
      launches(limit: \$limit, offset: \$offset, order: \$order) {
        mission_name
        launch_year
        launch_date_unix
        launch_date_utc
        launch_success
        upcoming
        details
        rocket {
          rocket_name
          rocket_type
        }
        launch_site {
          site_id
          site_name
          site_name_long
        }
        links {
          mission_patch
          mission_patch_small
          flickr_images
        }
      }
    }
  ''';

  /// Lightweight query for launch list items
  /// 
  /// Optimized for list views with minimal data transfer
  /// 
  /// Returns: List of launches with essential display information
  static const String getLaunchListItems = '''
    query GetLaunchListItems {
      launches {
        mission_name
        launch_year
        launch_date_unix
        launch_success
        upcoming
        rocket {
          rocket_name
          rocket_type
        }
        launch_site {
          site_name
        }
        links {
          mission_patch_small
        }
      }
    }
  ''';

  /// Query to search launches by mission name
  /// 
  /// Variables:
  /// - searchTerm: String! (required) - The search term to match against mission names
  /// 
  /// Returns: List of launches matching the search criteria
  static const String searchLaunches = '''
    query SearchLaunches(\$searchTerm: String!) {
      launches(find: { mission_name: { \$regex: \$searchTerm, \$options: "i" } }) {
        mission_name
        launch_year
        launch_date_unix
        launch_date_utc
        launch_success
        upcoming
        details
        rocket {
          rocket_name
          rocket_type
        }
        launch_site {
          site_id
          site_name
          site_name_long
        }
        links {
          mission_patch
          mission_patch_small
          flickr_images
        }
      }
    }
  ''';

  /// Query to fetch launches by year
  /// 
  /// Variables:
  /// - year: String! (required) - The launch year to filter by
  /// 
  /// Returns: List of launches from the specified year
  static const String getLaunchesByYear = '''
    query GetLaunchesByYear(\$year: String!) {
      launches(find: { launch_year: \$year }) {
        mission_name
        launch_year
        launch_date_unix
        launch_date_utc
        launch_success
        upcoming
        details
        rocket {
          rocket_name
          rocket_type
        }
        launch_site {
          site_name
        }
        links {
          mission_patch_small
          flickr_images
        }
      }
    }
  ''';

  /// Query to fetch successful launches only
  /// 
  /// Returns: List of launches that were successful
  static const String getSuccessfulLaunches = '''
    query GetSuccessfulLaunches {
      launches(find: { launch_success: true }) {
        mission_name
        launch_year
        launch_date_unix
        launch_date_utc
        launch_success
        details
        rocket {
          rocket_name
          rocket_type
        }
        launch_site {
          site_name
        }
        links {
          mission_patch_small
          flickr_images
        }
      }
    }
  ''';

  /// Query to fetch failed launches only
  /// 
  /// Returns: List of launches that failed with failure details
  static const String getFailedLaunches = '''
    query GetFailedLaunches {
      launches(find: { launch_success: false }) {
        mission_name
        launch_year
        launch_date_unix
        launch_date_utc
        launch_success
        launch_failure_details {
          time
          altitude
          reason
        }
        details
        rocket {
          rocket_name
          rocket_type
        }
        launch_site {
          site_name
        }
        links {
          mission_patch_small
        }
      }
    }
  ''';

  /// Query to fetch launches with images only
  /// 
  /// Used for image gallery features
  /// 
  /// Returns: List of launches that have Flickr images available
  static const String getLaunchesWithImages = '''
    query GetLaunchesWithImages {
      launches(find: { "links.flickr_images": { \$ne: [] } }) {
        mission_name
        launch_date_unix
        launch_success
        upcoming
        rocket {
          rocket_name
        }
        links {
          mission_patch
          flickr_images
        }
      }
    }
  ''';

  /// Query to get next upcoming launch
  /// 
  /// Returns: The next scheduled launch
  static const String getNextLaunch = '''
    query GetNextLaunch {
      launchNext {
        mission_name
        launch_date_unix
        launch_date_utc
        launch_date_local
        is_tentative
        tentative_max_precision
        details
        rocket {
          rocket_name
          rocket_type
        }
        launch_site {
          site_name
          site_name_long
        }
        links {
          mission_patch
          mission_patch_small
          presskit
          article_link
          wikipedia
          video_link
          youtube_id
        }
      }
    }
  ''';

  /// Query to get latest launch
  /// 
  /// Returns: The most recent completed launch
  static const String getLatestLaunch = '''
    query GetLatestLaunch {
      launchLatest {
        mission_name
        launch_date_unix
        launch_date_utc
        launch_success
        details
        rocket {
          rocket_name
          rocket_type
        }
        launch_site {
          site_name
        }
        links {
          mission_patch
          mission_patch_small
          article_link
          wikipedia
          video_link
          flickr_images
        }
      }
    }
  ''';
}
