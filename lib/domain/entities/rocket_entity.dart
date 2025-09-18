// Domain entity representing physical dimensions
class DimensionsEntity {
  final double? meters;
  final double? feet;

  const DimensionsEntity({this.meters, this.feet});
  
  factory DimensionsEntity.fromJson(Map<String, dynamic> json) {
    return DimensionsEntity(
      meters: json['meters']?.toDouble(),
      feet: json['feet']?.toDouble(),
    );
  }
}

// Domain entity representing mass measurements
class MassEntity {
  final int? kg;
  final int? lb;

  const MassEntity({this.kg, this.lb});
  
  factory MassEntity.fromJson(Map<String, dynamic> json) {
    return MassEntity(
      kg: json['kg'],
      lb: json['lb'] ?? 0,
    );
  }
}

// Domain entity representing thrust measurements
class ThrustEntity {
  final int? kN;
  final int? lbf;

  const ThrustEntity({this.kN, this.lbf});
  
  factory ThrustEntity.fromJson(Map<String, dynamic> json) {
    return ThrustEntity(
      kN: json['kN'],
      lbf: json['lbf'],
    );
  }
}

// Domain entity representing rocket stage information
class StageEntity {
  final ThrustEntity? thrustSeaLevel;
  final ThrustEntity? thrustVacuum;
  final ThrustEntity? thrust;
  final bool? reusable;
  final int? engines;
  final double? fuelAmountTons;
  final int? burnTimeSec;

  const StageEntity({
    this.thrustSeaLevel,
    this.thrustVacuum,
    this.thrust,
    this.reusable,
    this.engines,
    this.fuelAmountTons,
    this.burnTimeSec,
  });
  
  factory StageEntity.fromJson(Map<String, dynamic> json) {
    return StageEntity(
      thrustSeaLevel: json['thrust_sea_level'] != null 
          ? ThrustEntity.fromJson(json['thrust_sea_level']) 
          : null,
      thrustVacuum: json['thrust_vacuum'] != null 
          ? ThrustEntity.fromJson(json['thrust_vacuum']) 
          : null,
      thrust: json['thrust'] != null 
          ? ThrustEntity.fromJson(json['thrust']) 
          : null,
      reusable: json['reusable'],
      engines: json['engines'],
      fuelAmountTons: json['fuel_amount_tons']?.toDouble(),
      burnTimeSec: json['burn_time_sec'],
    );
  }
}

// Domain entity representing engine specifications
class EngineEntity {
  final Map<String, int>? isp;
  final ThrustEntity? thrustSeaLevel;
  final ThrustEntity? thrustVacuum;
  final int? number;
  final String? type;
  final String? version;
  final String? layout;
  final int? engineLossMax;
  final String? propellant1;
  final String? propellant2;
  final double? thrustToWeight;

  const EngineEntity({
    this.isp,
    this.thrustSeaLevel,
    this.thrustVacuum,
    this.number,
    this.type,
    this.version,
    this.layout,
    this.engineLossMax,
    this.propellant1,
    this.propellant2,
    this.thrustToWeight,
  });
  
  factory EngineEntity.fromJson(Map<String, dynamic> json) {
    return EngineEntity(
      isp: json['isp'] != null ? Map<String, int>.from(json['isp']) : null,
      thrustSeaLevel: json['thrust_sea_level'] != null 
          ? ThrustEntity.fromJson(json['thrust_sea_level']) 
          : null,
      thrustVacuum: json['thrust_vacuum'] != null 
          ? ThrustEntity.fromJson(json['thrust_vacuum']) 
          : null,
      number: json['number'],
      type: json['type'],
      version: json['version'],
      layout: json['layout'],
      engineLossMax: json['engine_loss_max'],
      propellant1: json['propellant_1'],
      propellant2: json['propellant_2'],
      thrustToWeight: json['thrust_to_weight']?.toDouble(),
    );
  }
}

// Domain entity representing payload weight capacity
class PayloadWeightEntity {
  final String id;
  final String name;
  final int kg;
  final int lb;

  const PayloadWeightEntity({
    required this.id,
    required this.name,
    required this.kg,
    required this.lb,
  });
  
  factory PayloadWeightEntity.fromJson(Map<String, dynamic> json) {
    return PayloadWeightEntity(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      kg: json['kg'] ?? 0,
      lb: json['lb'] ?? 0,
    );
  }
}

// Domain entity representing a SpaceX rocket
// This entity represents the business logic layer's view of a rocket,
class RocketEntity {
  final String id;
  final String name;
  final String type;
  final bool active;
  final int stages;
  final int boosters;
  final int? costPerLaunch;
  final int? successRatePct;
  final String? firstFlight;
  final String country;
  final String company;
  final String? wikipedia;
  final String? description;
  final DimensionsEntity? height;
  final DimensionsEntity? diameter;
  final MassEntity? mass;
  final StageEntity? firstStage;
  final StageEntity? secondStage;
  final EngineEntity? engines;
  final List<PayloadWeightEntity> payloadWeights;
  final List<String> flickrImages;

  const RocketEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.active,
    required this.stages,
    required this.boosters,
    this.costPerLaunch,
    this.successRatePct,
    this.firstFlight,
    required this.country,
    required this.company,
    this.wikipedia,
    this.description,
    this.height,
    this.diameter,
    this.mass,
    this.firstStage,
    this.secondStage,
    this.engines,
    this.payloadWeights = const [],
    this.flickrImages = const [],
  });
  
  factory RocketEntity.fromJson(Map<String, dynamic> json) {
    return RocketEntity(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      active: json['active'] ?? false,
      stages: json['stages'] ?? 0,
      boosters: json['boosters'] ?? 0,
      costPerLaunch: json['cost_per_launch'],
      successRatePct: json['success_rate_pct'],
      firstFlight: json['first_flight'],
      country: json['country'] ?? '',
      company: json['company'] ?? '',
      wikipedia: json['wikipedia'],
      description: json['description'],
      height: json['height'] != null 
          ? DimensionsEntity.fromJson(json['height']) 
          : null,
      diameter: json['diameter'] != null 
          ? DimensionsEntity.fromJson(json['diameter']) 
          : null,
      mass: json['mass'] != null 
          ? MassEntity.fromJson(json['mass']) 
          : null,
      firstStage: json['first_stage'] != null 
          ? StageEntity.fromJson(json['first_stage']) 
          : null,
      secondStage: json['second_stage'] != null 
          ? StageEntity.fromJson(json['second_stage']) 
          : null,
      engines: json['engines'] != null 
          ? EngineEntity.fromJson(json['engines']) 
          : null,
      payloadWeights: json['payload_weights'] != null
          ? List<PayloadWeightEntity>.from(
              json['payload_weights'].map((x) => PayloadWeightEntity.fromJson(x))
            )
          : [],
      flickrImages: json['flickr_images'] != null
          ? List<String>.from(json['flickr_images'])
          : [],
    );
  }

  String get formattedCost {
    if (costPerLaunch == null) return 'N/A';
    return '\$${(costPerLaunch! / 1000000).toStringAsFixed(1)}M';
  }

  String get formattedSuccessRate {
    if (successRatePct == null) return 'N/A';
    return '$successRatePct%';
  }

  String get formattedHeight {
    if (height?.meters == null) return 'N/A';
    return '${height!.meters!.toStringAsFixed(1)}m';
  }

  String get formattedMass {
    if (mass?.kg == null) return 'N/A';
    return '${(mass!.kg! / 1000).toStringAsFixed(1)}t';
  }

  bool get hasImages => flickrImages.isNotEmpty;
  
  String? get primaryImage => flickrImages.isNotEmpty ? flickrImages.first : null;
  
  String get subtitle {
    if (type.toLowerCase().contains('rocket')) {
      return stages > 1 ? '$stages-Stage Rocket' : 'Single-Stage Rocket';
    }
    return type;
  }
  
  String get category {
    switch (name.toLowerCase()) {
      case 'falcon 1':
        return 'Light-Lift Launch Vehicle';
      case 'falcon 9':
        return 'Reusable Two-Stage Rocket';
      case 'falcon heavy':
        return 'Heavy-Lift Launch Vehicle';
      case 'starship':
        return 'Interplanetary Spacecraft';
      default:
        return 'Launch Vehicle';
    }
  }

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

// Enum representing rocket operational status
enum RocketStatus {
  excellent,
  good,
  average,
  retired,
}
