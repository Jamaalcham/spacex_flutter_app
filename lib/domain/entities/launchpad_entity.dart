// Launchpad entity for domain layer
class LaunchpadEntity {
  final String id;
  final String name;
  final String? details;
  final String? status;
  final int? successfulLaunches;
  final LaunchpadLocationEntity? location;

  const LaunchpadEntity({
    required this.id,
    required this.name,
    this.details,
    this.status,
    this.successfulLaunches,
    this.location,
  });

  // Creates a LaunchpadEntity from JSON data
  factory LaunchpadEntity.fromJson(Map<String, dynamic> json) {
    return LaunchpadEntity(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      details: json['details'],
      status: json['status'],
      successfulLaunches: json['successful_launches'],
      location: json['location'] != null 
          ? LaunchpadLocationEntity.fromJson(json['location'])
          : null,
    );
  }
}

// Location entity for launchpad
class LaunchpadLocationEntity {
  final String name;
  final String region;

  const LaunchpadLocationEntity({
    required this.name,
    required this.region,
  });

  // Creates a LaunchpadLocationEntity from JSON data
  factory LaunchpadLocationEntity.fromJson(Map<String, dynamic> json) {
    return LaunchpadLocationEntity(
      name: json['name'] ?? '',
      region: json['region'] ?? '',
    );
  }
}
