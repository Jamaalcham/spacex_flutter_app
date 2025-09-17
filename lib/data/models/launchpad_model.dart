import '../../domain/entities/launchpad_entity.dart';

// GraphQL data model for Launchpad
class LaunchpadModel extends LaunchpadEntity {
  const LaunchpadModel({
    required super.id,
    required super.name,
    super.details,
    super.status,
    super.successfulLaunches,
    super.location,
  });

  factory LaunchpadModel.fromJson(Map<String, dynamic> json) {
    return LaunchpadModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      details: json['details'] as String?,
      status: json['status'] as String?,
      successfulLaunches: json['successful_launches'] as int?,
      location: json['location'] != null 
          ? LaunchpadLocationModel.fromJson(json['location'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'details': details,
      'status': status,
      'successful_launches': successfulLaunches,
      'location': location != null && location is LaunchpadLocationModel 
          ? (location as LaunchpadLocationModel).toJson()
          : null,
    };
  }
}

// Location model for launchpad
class LaunchpadLocationModel extends LaunchpadLocationEntity {
  const LaunchpadLocationModel({
    required super.name,
    required super.region,
  });

  factory LaunchpadLocationModel.fromJson(Map<String, dynamic> json) {
    return LaunchpadLocationModel(
      name: json['name'] as String? ?? '',
      region: json['region'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'region': region,
    };
  }
}
