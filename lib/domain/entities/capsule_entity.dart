//  Domain entity representing a SpaceX capsule
//  This entity represents the business logic layer's view of a capsule,
// independent of data sources or presentation concerns.
class CapsuleEntity {
  // Unique identifier for the capsule
  final String id;
  
  //  Serial number of the capsule
  final String? serial;
  final String? type;
  final String? status;

  final int? reuseCount;
  final int? waterLandings;

  final int? landLandings;
  final String? lastUpdate;

  final List<String> launches;

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

  bool get isActive => status?.toLowerCase() == 'active';

  bool get isRetired => status?.toLowerCase() == 'retired';

  bool get isDestroyed => status?.toLowerCase() == 'destroyed';

  int get totalLandings => (waterLandings ?? 0) + (landLandings ?? 0);

  int get totalFlights => launches.length;

  bool get hasFlown => launches.isNotEmpty;

  bool get hasDetails => details != null && details!.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CapsuleEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  factory CapsuleEntity.fromJson(Map<String, dynamic> json) {
    return CapsuleEntity(
      id: json['id'] ?? '',
      serial: json['serial'],
      type: json['type'],
      status: json['status'],
      reuseCount: json['reuse_count'],
      waterLandings: json['water_landings'],
      landLandings: json['land_landings'],
      lastUpdate: json['last_update'],
      launches: List<String>.from(json['launches'] ?? []),
      details: json['details'],
    );
  }

  @override
  String toString() {
    return 'CapsuleEntity(id: $id, serial: $serial, status: $status, flights: ${launches.length})';
  }
}
