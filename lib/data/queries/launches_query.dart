const String launchesQuery = '''
  query LaunchesPast {
    launchesPast {
      details
      launch_date_local
      mission_name
      upcoming
      launch_success
      launch_year
    }
    launchesUpcoming {
      details
      launch_date_local
      mission_name
      upcoming
      launch_success
      launch_year
    }
  }
''';

const String upcomingLaunchesQuery = '''
  query UpcomingLaunches(\$limit: Int) {
    launchesUpcoming(limit: \$limit) {
      details
      launch_date_local
      mission_name
      upcoming
      launch_success
      launch_year
    }
  }
''';

const String pastLaunchesQuery = '''
  query PastLaunches(\$limit: Int) {
    launchesPast(limit: \$limit) {
      details
      launch_date_local
      mission_name
      upcoming
      launch_success
      launch_year
    }
  }
''';

// Optimized query for initial launch loading with pagination
const String paginatedLaunchesQuery = '''
  query PaginatedLaunches(\$limit: Int, \$offset: Int) {
    launchesPast(limit: \$limit, offset: \$offset) {
      details
      launch_date_local
      mission_name
      upcoming
      launch_success
      launch_year
    }
  }
''';

// Quick stats query for getting counts without full data
const String launchStatsQuery = '''
  query LaunchStats {
    launchesPast(limit: 1) {
      mission_name
    }
    launchesUpcoming(limit: 1) {
      mission_name
    }
  }
''';

const String launchpadsQuery = '''
  query Launchpads(\$limit: Int, \$offset: Int) {
    launchpads(limit: \$limit, offset: \$offset) {
      details
      name
      status
      successful_launches
      location {
        name
        region
      }
    }
  }
''';

const String landpadsQuery = '''
  query Landpads(\$limit: Int, \$offset: Int) {
    landpads(limit: \$limit, offset: \$offset) {
      details
      full_name
      landing_type
      location {
        name
        region
      }
      status
      successful_landings
    }
  }
''';

// Combined query for the main screen that includes all data
const String allDataQuery = '''
  query AllSpaceXData {
    launchesPast {
      details
      launch_date_local
      mission_name
      upcoming
      launch_success
      launch_year
    }
    launchesUpcoming {
      details
      launch_date_local
      mission_name
      upcoming
      launch_success
      launch_year
    }
    launchpads(limit: 10) {
      details
      name
      status
      successful_launches
      location {
        name
        region
      }
    }
    landpads(limit: 10) {
      details
      full_name
      landing_type
      location {
        name
        region
      }
      status
      successful_landings
    }
  }
''';
