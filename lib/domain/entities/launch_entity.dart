/// Domain entity representing a SpaceX launch
/// 
/// This entity encapsulates the business logic and rules for launch data,
/// providing a clean interface for the presentation layer while being
/// independent of data source implementation details.
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

  /// Checks if there are any Flickr images available
  bool get hasFlickrImages => flickrImages != null && flickrImages!.isNotEmpty;

  /// Returns the best available mission patch image
  String? get bestMissionPatch => missionPatch ?? missionPatchSmall;
}

/// Domain entity for launch rocket information
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

  /// Returns display name (short name if available, otherwise full name)
  String get displayName => nameShort ?? name;
}
