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

  // Creates a LandpadEntity from JSON data
  factory LandpadEntity.fromJson(Map<String, dynamic> json) {
    return LandpadEntity(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      details: json['details'],
      landingType: json['landing_type'],
      status: json['status'],
      successfulLandings: json['successful_landings'],
      location: json['location'] != null 
          ? LandpadLocationEntity.fromJson(json['location'])
          : null,
    );
  }
}

// Location entity for landpad
class LandpadLocationEntity {
  final String name;
  final String region;

  const LandpadLocationEntity({
    required this.name,
    required this.region,
  });

  // Creates a LandpadLocationEntity from JSON data
  factory LandpadLocationEntity.fromJson(Map<String, dynamic> json) {
    return LandpadLocationEntity(
      name: json['name'] ?? '',
      region: json['region'] ?? '',
    );
  }
}
