import 'dart:convert';

/// Data model representing a SpaceX mission
/// 
/// This model contains all the essential information about SpaceX missions
/// including mission details, manufacturers, and associated metadata.
/// 
/// Example usage:
/// ```dart
/// final mission = Mission.fromJson(jsonData);
/// print(mission.name); // Mission name
/// ```
class Mission {
  /// Unique identifier for the mission
  final String id;
  
  /// Display name of the mission
  final String name;
  
  /// Detailed description of the mission objectives and goals
  final String? description;
  
  /// List of companies/organizations that manufactured mission components
  final List<String> manufacturers;
  
  /// Wikipedia URL for additional mission information
  final String? wikipedia;
  
  /// Official website URL for the mission
  final String? website;
  
  /// Twitter handle or URL for mission updates
  final String? twitter;

  const Mission({
    required this.id,
    required this.name,
    this.description,
    required this.manufacturers,
    this.wikipedia,
    this.website,
    this.twitter,
  });

  /// Creates a Mission instance from JSON data
  /// 
  /// Handles null safety and provides default values for optional fields
  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Mission',
      description: json['description']?.toString(),
      manufacturers: json['manufacturers'] != null 
          ? List<String>.from(json['manufacturers'].map((x) => x.toString()))
          : [],
      wikipedia: json['wikipedia']?.toString(),
      website: json['website']?.toString(),
      twitter: json['twitter']?.toString(),
    );
  }

  /// Converts Mission instance to JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'manufacturers': manufacturers,
      'wikipedia': wikipedia,
      'website': website,
      'twitter': twitter,
    };
  }

  /// Creates a Mission instance from JSON string
  factory Mission.fromRawJson(String str) => Mission.fromJson(json.decode(str));

  /// Converts Mission instance to JSON string
  String toRawJson() => json.encode(toJson());

  /// Creates a copy of this Mission with optionally updated fields
  Mission copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? manufacturers,
    String? wikipedia,
    String? website,
    String? twitter,
  }) {
    return Mission(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      manufacturers: manufacturers ?? this.manufacturers,
      wikipedia: wikipedia ?? this.wikipedia,
      website: website ?? this.website,
      twitter: twitter ?? this.twitter,
    );
  }

  /// Returns true if the mission has any external links
  bool get hasLinks => wikipedia != null || website != null || twitter != null;

  /// Returns the number of manufacturers involved in the mission
  int get manufacturerCount => manufacturers.length;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Mission && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Mission(id: $id, name: $name, manufacturers: ${manufacturers.length})';
  }
}
