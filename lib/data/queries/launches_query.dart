const String launchesQuery = '''
  query Launches {
    launchesUpcoming(limit: 10) {
      id
      mission_name
      details
      launch_success
      upcoming
      launch_date_utc
      launch_date_unix
      rocket {
        rocket_name
      }
    }
    launchesPast(limit: 20) {
      id
      mission_name
      details
      launch_success
      upcoming
      launch_date_utc
      launch_date_unix
      rocket {
        rocket_name
      }
    }
    launchpads {
      id
      name
      details
      status
      successful_launches
      location {
        name
        region
      }
    }
    landpads {
      id
      full_name
      details
      landing_type
      status
      successful_landings
      location {
        name
        region
      }
    }
  }
''';
