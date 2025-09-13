/// Domain entity representing physical dimensions
class DimensionsEntity {
  final double? meters;
  final double? feet;

  const DimensionsEntity({this.meters, this.feet});
}

/// Domain entity representing mass measurements
class MassEntity {
  final int? kg;
  final int? lb;

  const MassEntity({this.kg, this.lb});
}


/// Domain entity representing a SpaceX rocket
/// 
/// This entity represents the business logic layer's view of a rocket,
/// containing essential specifications and operational data.
class RocketEntity {
  final String id;
  final String name;
  final String type;
  final bool active;
  final int? costPerLaunch;
  final int? successRatePct;
  final String? firstFlight;
  final String country;
  final String company;
  final DimensionsEntity? height;
  final DimensionsEntity? diameter;
  final MassEntity? mass;
  final String? description;

  const RocketEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.active,
    this.costPerLaunch,
    this.successRatePct,
    this.firstFlight,
    required this.country,
    required this.company,
    this.height,
    this.diameter,
    this.mass,
    this.description,
  });

  /// Returns formatted cost per launch string
  String get formattedCost {
    if (costPerLaunch == null) return 'N/A';
    return '\$${(costPerLaunch! / 1000000).toStringAsFixed(1)}M';
  }

  /// Returns formatted success rate string
  String get formattedSuccessRate {
    if (successRatePct == null) return 'N/A';
    return '$successRatePct%';
  }

  /// Returns formatted height string (meters)
  String get formattedHeight {
    if (height?.meters == null) return 'N/A';
    return '${height!.meters!.toStringAsFixed(1)}m';
  }

  /// Returns formatted mass string (kg)
  String get formattedMass {
    if (mass?.kg == null) return 'N/A';
    return '${(mass!.kg! / 1000).toStringAsFixed(1)}t';
  }

  /// Returns true if rocket has images available
  bool get hasImages => false; // No image data in current schema

  /// Returns status based on active state and success rate
  RocketStatus get status {
    if (!active) return RocketStatus.retired;
    if (successRatePct != null && successRatePct! >= 90) return RocketStatus.excellent;
    if (successRatePct != null && successRatePct! >= 75) return RocketStatus.good;
    return RocketStatus.average;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RocketEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'RocketEntity(id: $id, name: $name, active: $active, successRate: $successRatePct%)';
  }
}

/// Enum representing rocket operational status
enum RocketStatus {
  excellent,
  good,
  average,
  retired,
}
