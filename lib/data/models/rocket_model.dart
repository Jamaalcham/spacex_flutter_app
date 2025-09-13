import 'dart:convert';

/// Data model representing physical dimensions
/// 
/// Used for rocket height, diameter, and other measurements
class Dimensions {
  /// Measurement in meters
  final double? meters;
  
  /// Measurement in feet
  final double? feet;

  const Dimensions({
    this.meters,
    this.feet,
  });

  factory Dimensions.fromJson(Map<String, dynamic> json) {
    return Dimensions(
      meters: json['meters']?.toDouble(),
      feet: json['feet']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meters': meters,
      'feet': feet,
    };
  }
}

/// Data model representing mass measurements
/// 
/// Used for rocket mass in different units
class Mass {
  /// Mass in kilograms
  final int? kg;
  
  /// Mass in pounds
  final int? lb;

  const Mass({
    this.kg,
    this.lb,
  });

  factory Mass.fromJson(Map<String, dynamic> json) {
    return Mass(
      kg: json['kg']?.toInt(),
      lb: json['lb']?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kg': kg,
      'lb': lb,
    };
  }
}


/// Data model representing a SpaceX rocket
/// 
/// This comprehensive model contains all rocket specifications,
/// performance data, and operational information.
/// 
/// Example usage:
/// ```dart
/// final rocket = Rocket.fromJson(jsonData);
/// print('${rocket.name} - Success Rate: ${rocket.successRatePct}%');
/// ```
class Rocket {
  /// Unique identifier for the rocket
  final String id;
  
  /// Display name of the rocket
  final String name;
  
  /// Type/classification of the rocket
  final String type;
  
  /// Whether the rocket is currently active
  final bool active;
  
  /// Cost per launch in USD
  final int? costPerLaunch;
  
  /// Success rate percentage
  final int? successRatePct;
  
  /// Date of first flight
  final String? firstFlight;
  
  /// Country of origin
  final String country;
  
  /// Company that built the rocket
  final String company;
  
  /// Physical height of the rocket
  final Dimensions? height;
  
  /// Physical diameter of the rocket
  final Dimensions? diameter;
  
  /// Mass of the rocket
  final Mass? mass;
  
  /// Detailed description of the rocket
  final String? description;

  const Rocket({
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

  /// Creates a Rocket instance from JSON data
  /// 
  /// Handles complex nested objects and provides safe defaults
  factory Rocket.fromJson(Map<String, dynamic> json) {
    return Rocket(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Rocket',
      type: json['type']?.toString() ?? '',
      active: json['active'] ?? false,
      costPerLaunch: json['cost_per_launch']?.toInt(),
      successRatePct: json['success_rate_pct']?.toInt(),
      firstFlight: json['first_flight']?.toString(),
      country: json['country']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      height: json['height'] != null ? Dimensions.fromJson(json['height']) : null,
      diameter: json['diameter'] != null ? Dimensions.fromJson(json['diameter']) : null,
      mass: json['mass'] != null ? Mass.fromJson(json['mass']) : null,
      description: json['description']?.toString(),
    );
  }

  /// Converts Rocket instance to JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'active': active,
      'cost_per_launch': costPerLaunch,
      'success_rate_pct': successRatePct,
      'first_flight': firstFlight,
      'country': country,
      'company': company,
      'height': height?.toJson(),
      'diameter': diameter?.toJson(),
      'mass': mass?.toJson(),
      'description': description,
    };
  }

  /// Creates a Rocket instance from JSON string
  factory Rocket.fromRawJson(String str) => Rocket.fromJson(json.decode(str));

  /// Converts Rocket instance to JSON string
  String toRawJson() => json.encode(toJson());

  /// Creates a copy of this Rocket with optionally updated fields
  Rocket copyWith({
    String? id,
    String? name,
    String? type,
    bool? active,
    int? costPerLaunch,
    int? successRatePct,
    String? firstFlight,
    String? country,
    String? company,
    Dimensions? height,
    Dimensions? diameter,
    Mass? mass,
    String? description,
  }) {
    return Rocket(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      active: active ?? this.active,
      costPerLaunch: costPerLaunch ?? this.costPerLaunch,
      successRatePct: successRatePct ?? this.successRatePct,
      firstFlight: firstFlight ?? this.firstFlight,
      country: country ?? this.country,
      company: company ?? this.company,
      height: height ?? this.height,
      diameter: diameter ?? this.diameter,
      mass: mass ?? this.mass,
      description: description ?? this.description,
    );
  }

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

  /// Returns status color based on active state and success rate
  String get statusColor {
    if (!active) return 'inactive';
    if (successRatePct != null && successRatePct! >= 90) return 'excellent';
    if (successRatePct != null && successRatePct! >= 75) return 'good';
    return 'average';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Rocket && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Rocket(id: $id, name: $name, active: $active, successRate: $successRatePct%)';
  }
}
