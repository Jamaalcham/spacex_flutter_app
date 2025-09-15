/// Domain entity representing a SpaceX capsule
/// 
/// This entity represents the business logic layer's view of a capsule,
/// independent of data sources or presentation concerns.
/// It contains only the essential business data and rules.
class CapsuleEntity {
  /// Unique identifier for the capsule
  final String id;
  
  /// Serial number of the capsule
  final String? serial;
  
  /// Type of capsule (Dragon 1.0, Dragon 1.1, Dragon 2.0, etc.)
  final String? type;
  
  /// Current status of the capsule (active, retired, destroyed, unknown)
  final String? status;
  
  /// Number of times this capsule has been reused
  final int? reuseCount;
  
  /// Water landing count
  final int? waterLandings;
  
  /// Land landing count
  final int? landLandings;
  
  /// Date of last update (ISO string)
  final String? lastUpdate;
  
  /// List of launches this capsule was used in
  final List<String> launches;
  
  /// Details about the capsule
  final String? details;

  const CapsuleEntity({
    required this.id,
    this.serial,
    this.type,
    this.status,
    this.reuseCount,
    this.waterLandings,
    this.landLandings,
    this.lastUpdate,
    required this.launches,
    this.details,
  });

  /// Returns true if the capsule is currently active
  bool get isActive => status?.toLowerCase() == 'active';

  /// Returns true if the capsule is retired
  bool get isRetired => status?.toLowerCase() == 'retired';

  /// Returns true if the capsule has been destroyed
  bool get isDestroyed => status?.toLowerCase() == 'destroyed';

  /// Returns the total number of landings
  int get totalLandings => (waterLandings ?? 0) + (landLandings ?? 0);

  /// Returns the total number of flights
  int get totalFlights => launches.length;

  /// Returns true if the capsule has flown missions
  bool get hasFlown => launches.isNotEmpty;

  /// Returns true if the capsule has details
  bool get hasDetails => details != null && details!.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CapsuleEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CapsuleEntity(id: $id, serial: $serial, status: $status, flights: ${launches.length})';
  }
}
