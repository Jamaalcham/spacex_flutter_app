/// Simplified Launch model matching the actual GraphQL API response
class LaunchSimple {
  final String id;
  final String name;
  final String? details;
  final bool? success;
  final bool upcoming;
  final String? dateUtc;
  final int? dateUnix;
  final LaunchRocketSimple rocket;

  const LaunchSimple({
    required this.id,
    required this.name,
    this.details,
    this.success,
    required this.upcoming,
    this.dateUtc,
    this.dateUnix,
    required this.rocket,
  });

  // Computed property for backward compatibility
  String get launchYear {
    if (dateUtc != null) {
      try {
        return DateTime.parse(dateUtc!).year.toString();
      } catch (e) {
        return '';
      }
    }
    return '';
  }

  // Backward compatibility getters
  String get missionName => name;
  bool? get launchSuccess => success;
  String? get launchDateUtc => dateUtc;

  factory LaunchSimple.fromJson(Map<String, dynamic> json) {
    return LaunchSimple(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Mission',
      details: json['details']?.toString(),
      success: json['success'],
      upcoming: json['upcoming'] ?? false,
      dateUtc: json['date_utc']?.toString(),
      dateUnix: json['date_unix']?.toInt(),
      rocket: LaunchRocketSimple.fromJson(json['rocket'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'details': details,
      'success': success,
      'upcoming': upcoming,
      'date_utc': dateUtc,
      'date_unix': dateUnix,
      'rocket': rocket.toJson(),
    };
  }
}

/// Simplified rocket model for launches
class LaunchRocketSimple {
  final String name;

  const LaunchRocketSimple({
    required this.name,
  });

  // Backward compatibility getter
  String get rocketName => name;

  factory LaunchRocketSimple.fromJson(Map<String, dynamic> json) {
    return LaunchRocketSimple(
      name: json['name']?.toString() ?? 'Unknown Rocket',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
