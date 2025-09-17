import '../../domain/entities/landpad_entity.dart';

// GraphQL data model for Landpad
class LandpadModel extends LandpadEntity {
  const LandpadModel({
    required super.id,
    required super.fullName,
    super.details,
    super.landingType,
    super.status,
    super.successfulLandings,
    super.location,
  });

  factory LandpadModel.fromJson(Map<String, dynamic> json) {
    return LandpadModel(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      details: json['details'] as String?,
      landingType: json['landing_type'] as String?,
      status: json['status'] as String?,
      successfulLandings: json['successful_landings'] as int?,
      location: json['location'] != null 
          ? LandpadLocationModel.fromJson(json['location'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'details': details,
      'landing_type': landingType,
      'status': status,
      'successful_landings': successfulLandings,
      'location': location != null && location is LandpadLocationModel 
          ? (location as LandpadLocationModel).toJson()
          : null,
    };
  }
}

// Location model for landpad
class LandpadLocationModel extends LandpadLocationEntity {
  const LandpadLocationModel({
    required super.name,
    required super.region,
  });

  factory LandpadLocationModel.fromJson(Map<String, dynamic> json) {
    return LandpadLocationModel(
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
