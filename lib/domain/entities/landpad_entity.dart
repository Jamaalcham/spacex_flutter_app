// Landpad entity for domain layer
class LandpadEntity {
  final String id;
  final String fullName;
  final String? details;
  final String? landingType;
  final String? status;
  final int? successfulLandings;
  final LandpadLocationEntity? location;

  const LandpadEntity({
    required this.id,
    required this.fullName,
    this.details,
    this.landingType,
    this.status,
    this.successfulLandings,
    this.location,
  });
}

// Location entity for landpad
class LandpadLocationEntity {
  final String name;
  final String region;

  const LandpadLocationEntity({
    required this.name,
    required this.region,
  });
}
