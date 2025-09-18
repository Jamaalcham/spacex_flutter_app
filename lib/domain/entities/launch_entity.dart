// Domain entity representing a SpaceX launch
class LaunchEntity {
  final int flightNumber;
  final String missionName;
  final DateTime? dateUtc;
  final bool? success;
  final bool? upcoming;
  final String? details;
  final LaunchLinksEntity? links;
  final LaunchRocketEntity? rocket;
  final LaunchSiteEntity? launchSite;

  const LaunchEntity({
    required this.flightNumber,
    required this.missionName,
    this.dateUtc,
    this.success,
    this.upcoming,
    this.details,
    this.links,
    this.rocket,
    this.launchSite,
  });

  factory LaunchEntity.fromJson(Map<String, dynamic> json) {
    return LaunchEntity(
      flightNumber: json['flight_number'] ?? 0,
      missionName: json['mission_name'] ?? '',
      dateUtc: json['launch_date_unix'] != null && json['launch_date_unix'] > 0
          ? DateTime.fromMillisecondsSinceEpoch(json['launch_date_unix'] * 1000)
          : null,
      success: json['launch_success'],
      upcoming: json['upcoming'],
      details: json['details'],
      links: json['links'] != null 
          ? LaunchLinksEntity.fromJson(json['links'])
          : null,
      rocket: json['rocket'] != null 
          ? LaunchRocketEntity.fromJson(json['rocket'])
          : null,
      launchSite: json['launch_site'] != null 
          ? LaunchSiteEntity.fromJson(json['launch_site'])
          : null,
    );
  }

  /// Returns formatted launch date
  String get formattedDate {
    if (dateUtc == null) return 'TBD';
    
    final now = DateTime.now();
    final difference = dateUtc!.difference(now);
    
    if (upcoming == true && difference.inDays > 0) {
      return 'T-${difference.inDays} days';
    } else if (upcoming == true && difference.inHours > 0) {
      return 'T-${difference.inHours} hours';
    } else if (upcoming == true && difference.inMinutes > 0) {
      return 'T-${difference.inMinutes} minutes';
    }
    
    return '${dateUtc!.day}/${dateUtc!.month}/${dateUtc!.year}';
  }

  /// Returns launch status as a readable string
  String get statusText {
    if (upcoming == true) return 'Upcoming';
    if (success == true) return 'Success';
    if (success == false) return 'Failed';
    return 'Unknown';
  }

  /// Returns status color based on launch outcome
  String get statusColor {
    if (upcoming == true) return 'blue';
    if (success == true) return 'green';
    if (success == false) return 'red';
    return 'grey';
  }

  /// Checks if launch has mission patch image
  bool get hasMissionPatch => links?.missionPatch != null;

  /// Checks if launch has video link
  bool get hasVideo => links?.videoLink != null;

  /// Checks if launch has article link
  bool get hasArticle => links?.article != null;

  /// Returns time until launch (for upcoming launches)
  Duration? get timeUntilLaunch {
    if (dateUtc == null || upcoming != true) return null;
    final now = DateTime.now();
    return dateUtc!.isAfter(now) ? dateUtc!.difference(now) : null;
  }

  /// Checks if launch is in the past
  bool get isPast => upcoming == false || (dateUtc?.isBefore(DateTime.now()) ?? false);

  /// Checks if launch is scheduled for today
  bool get isToday {
    if (dateUtc == null) return false;
    final now = DateTime.now();
    return dateUtc!.year == now.year &&
           dateUtc!.month == now.month &&
           dateUtc!.day == now.day;
  }

  /// Returns formatted rocket name with core info
  String get rocketInfo {
    if (rocket == null) return 'Unknown Rocket';
    return '${rocket!.name}${rocket!.coreSerial != null ? ' (${rocket!.coreSerial})' : ''}';
  }

  /// Returns formatted launch site name
  String get launchSiteInfo {
    if (launchSite == null) return 'Unknown Site';
    return '${launchSite!.name}${launchSite!.nameShort != null ? ' (${launchSite!.nameShort})' : ''}';
  }
}

/// Domain entity for launch links
class LaunchLinksEntity {
  final String? missionPatch;
  final String? missionPatchSmall;
  final String? article;
  final String? wikipedia;
  final String? videoLink;
  final List<String>? flickrImages;

  const LaunchLinksEntity({
    this.missionPatch,
    this.missionPatchSmall,
    this.article,
    this.wikipedia,
    this.videoLink,
    this.flickrImages,
  });

  /// Creates a LaunchLinksEntity from JSON data
  factory LaunchLinksEntity.fromJson(Map<String, dynamic> json) {
    return LaunchLinksEntity(
      missionPatch: json['mission_patch'],
      missionPatchSmall: json['mission_patch_small'],
      article: json['article_link'],
      wikipedia: json['wikipedia'],
      videoLink: json['video_link'],
      flickrImages: json['flickr_images'] != null 
          ? List<String>.from(json['flickr_images'])
          : null,
    );
  }

  // Checks if there are any Flickr images available
  bool get hasFlickrImages => flickrImages != null && flickrImages!.isNotEmpty;

  /// Returns the best available mission patch image
  String? get bestMissionPatch => missionPatch ?? missionPatchSmall;
}

// Domain entity for launch rocket information
class LaunchRocketEntity {
  final String? id;
  final String name;
  final String? type;
  final String? coreSerial;
  final int? coreReuse;
  final bool? landingSuccess;

  const LaunchRocketEntity({
    this.id,
    required this.name,
    this.type,
    this.coreSerial,
    this.coreReuse,
    this.landingSuccess,
  });

  /// Creates a LaunchRocketEntity from JSON data
  factory LaunchRocketEntity.fromJson(Map<String, dynamic> json) {
    return LaunchRocketEntity(
      id: json['rocket_id'],
      name: json['rocket_name'] ?? '',
      type: json['rocket_type'],
      coreSerial: json['core_serial'],
      coreReuse: json['core_reuse'],
      landingSuccess: json['landing_success'],
    );
  }

  /// Returns reuse information as formatted string
  String get reuseInfo {
    if (coreReuse == null) return 'New Core';
    return coreReuse! > 0 ? 'Reused (Flight ${coreReuse! + 1})' : 'New Core';
  }

  /// Returns landing status as formatted string
  String get landingInfo {
    if (landingSuccess == null) return 'No Landing Attempt';
    return landingSuccess! ? 'Landing Success' : 'Landing Failed';
  }
}

/// Domain entity for launch site information
class LaunchSiteEntity {
  final String? id;
  final String name;
  final String? nameShort;

  const LaunchSiteEntity({
    this.id,
    required this.name,
    this.nameShort,
  });

  /// Creates a LaunchSiteEntity from JSON data
  factory LaunchSiteEntity.fromJson(Map<String, dynamic> json) {
    return LaunchSiteEntity(
      id: json['site_id'],
      name: json['site_name'] ?? '',
      nameShort: json['site_name_short'],
    );
  }

  /// Returns display name (short name if available, otherwise full name)
  String get displayName => nameShort ?? name;
}
