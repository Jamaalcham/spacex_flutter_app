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
}

/// Location entity for launchpad
class LaunchpadLocationEntity {
  final String name;
  final String region;

  const LaunchpadLocationEntity({
    required this.name,
    required this.region,
  });
}
