/// Domain entity representing a SpaceX mission
/// 
/// This entity represents the business logic layer's view of a mission,
/// independent of data sources or presentation concerns.
/// It contains only the essential business data and rules.
class MissionEntity {
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

  const MissionEntity({
    required this.id,
    required this.name,
    this.description,
    required this.manufacturers,
    this.wikipedia,
    this.website,
    this.twitter,
  });

  /// Returns true if the mission has any external links
  bool get hasLinks => wikipedia != null || website != null || twitter != null;

  /// Returns the number of manufacturers involved in the mission
  int get manufacturerCount => manufacturers.length;

  /// Returns a formatted string of manufacturers
  String get manufacturersString => manufacturers.join(', ');

  /// Returns true if the mission has a description
  bool get hasDescription => description != null && description!.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MissionEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MissionEntity(id: $id, name: $name, manufacturers: ${manufacturers.length})';
  }
}
