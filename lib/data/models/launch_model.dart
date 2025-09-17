import 'dart:convert';

/// Data model representing launch links and media
/// 
/// Contains URLs for mission patches, articles, videos, and social media
class LaunchLinks {
  /// Mission patch image URL
  final String? missionPatch;
  
  /// Small mission patch image URL
  final String? missionPatchSmall;
  
  /// Reddit campaign URL
  final String? redditCampaign;
  
  /// Reddit launch URL
  final String? redditLaunch;
  
  /// Reddit recovery URL
  final String? redditRecovery;
  
  /// Reddit media URL
  final String? redditMedia;
  
  /// Press kit URL
  final String? presskit;
  
  /// Article link URL
  final String? articleLink;
  
  /// Wikipedia URL
  final String? wikipedia;
  
  /// Video link URL
  final String? videoLink;
  
  /// YouTube video ID
  final String? youtubeId;
  
  /// List of Flickr image URLs
  final List<String> flickrImages;

  const LaunchLinks({
    this.missionPatch,
    this.missionPatchSmall,
    this.redditCampaign,
    this.redditLaunch,
    this.redditRecovery,
    this.redditMedia,
    this.presskit,
    this.articleLink,
    this.wikipedia,
    this.videoLink,
    this.youtubeId,
    required this.flickrImages,
  });

  factory LaunchLinks.fromJson(Map<String, dynamic> json) {
    return LaunchLinks(
      missionPatch: json['mission_patch']?.toString(),
      missionPatchSmall: json['mission_patch_small']?.toString(),
      redditCampaign: json['reddit_campaign']?.toString(),
      redditLaunch: json['reddit_launch']?.toString(),
      redditRecovery: json['reddit_recovery']?.toString(),
      redditMedia: json['reddit_media']?.toString(),
      presskit: json['presskit']?.toString(),
      articleLink: json['article_link']?.toString(),
      wikipedia: json['wikipedia']?.toString(),
      videoLink: json['video_link']?.toString(),
      youtubeId: json['youtube_id']?.toString(),
      flickrImages: json['flickr_images'] != null 
          ? List<String>.from(json['flickr_images'].map((x) => x.toString()))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mission_patch': missionPatch,
      'mission_patch_small': missionPatchSmall,
      'reddit_campaign': redditCampaign,
      'reddit_launch': redditLaunch,
      'reddit_recovery': redditRecovery,
      'reddit_media': redditMedia,
      'presskit': presskit,
      'article_link': articleLink,
      'wikipedia': wikipedia,
      'video_link': videoLink,
      'youtube_id': youtubeId,
      'flickr_images': flickrImages,
    };
  }
}

/// Data model representing launch site information
/// 
/// Contains details about the launch location and facility
class LaunchSite {
  /// Site ID
  final String siteId;
  
  /// Site name
  final String siteName;
  
  /// Full site name
  final String siteNameLong;

  const LaunchSite({
    required this.siteId,
    required this.siteName,
    required this.siteNameLong,
  });

  factory LaunchSite.fromJson(Map<String, dynamic> json) {
    return LaunchSite(
      siteId: json['site_id']?.toString() ?? '',
      siteName: json['site_name']?.toString() ?? '',
      siteNameLong: json['site_name_long']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'site_id': siteId,
      'site_name': siteName,
      'site_name_long': siteNameLong,
    };
  }
}

/// Data model representing rocket information in launch context
/// 
/// Simplified rocket data specific to launch information
class LaunchRocket {
  /// Rocket ID
  final String rocketId;
  
  /// Rocket name
  final String rocketName;
  
  /// Rocket type
  final String rocketType;

  const LaunchRocket({
    required this.rocketId,
    required this.rocketName,
    required this.rocketType,
  });

  factory LaunchRocket.fromJson(Map<String, dynamic> json) {
    // Both GraphQL and REST API use rocket_name field
    return LaunchRocket(
      rocketId: json['rocket_id']?.toString() ?? '',
      rocketName: json['rocket_name']?.toString() ?? '',
      rocketType: json['rocket_type']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rocket_id': rocketId,
      'rocket_name': rocketName,
      'rocket_type': rocketType,
    };
  }
}

/// Data model representing a SpaceX launch
/// 
/// This comprehensive model contains all launch information including
/// mission details, rocket data, launch site, success status, and media links.
/// 
/// Example usage:
/// ```dart
/// final launch = Launch.fromJson(jsonData);
/// print('${launch.missionName} - ${launch.launchSuccess ? "Success" : "Failed"}');
/// ```
class Launch {
  /// Flight number (sequential launch number)
  final int flightNumber;
  
  /// Mission name
  final String missionName;
  
  /// Mission ID (if applicable)
  final List<String> missionId;
  
  /// Launch year
  final String launchYear;
  
  /// Launch date (Unix timestamp)
  final int launchDateUnix;
  
  /// Launch date (UTC string)
  final String launchDateUtc;
  
  /// Launch date (local string)
  final String launchDateLocal;
  
  /// Whether this is a tentative launch date
  final bool isTentative;
  
  /// Tentative maximum precision (if applicable)
  final String? tentativeMaxPrecision;
  
  /// Whether the launch was successful
  final bool? launchSuccess;
  
  /// Launch failure details (if failed)
  final Map<String, dynamic>? launchFailureDetails;
  
  /// Whether this is an upcoming launch
  final bool upcoming;
  
  /// Launch details and description
  final String? details;
  
  /// Rocket information
  final LaunchRocket rocket;
  
  /// Launch site information
  final LaunchSite? launchSite;
  
  /// Links to media and additional information
  final LaunchLinks links;
  
  /// Static fire date (UTC)
  final String? staticFireDateUtc;
  
  /// Static fire date (Unix timestamp)
  final int? staticFireDateUnix;
  
  /// Timeline of launch events
  final Map<String, dynamic>? timeline;
  
  /// Crew information (for crewed missions)
  final List<String> crew;

  const Launch({
    required this.flightNumber,
    required this.missionName,
    required this.missionId,
    required this.launchYear,
    required this.launchDateUnix,
    required this.launchDateUtc,
    required this.launchDateLocal,
    required this.isTentative,
    this.tentativeMaxPrecision,
    this.launchSuccess,
    this.launchFailureDetails,
    required this.upcoming,
    this.details,
    required this.rocket,
    this.launchSite,
    required this.links,
    this.staticFireDateUtc,
    this.staticFireDateUnix,
    this.timeline,
    required this.crew,
  });

  /// Creates a Launch instance from JSON data
  /// 
  /// Handles both REST API and GraphQL response formats
  factory Launch.fromJson(Map<String, dynamic> json) {
    // Handle GraphQL format (uses same field names as REST API)
    if (json.containsKey('id') && json.containsKey('mission_name')) {
      return Launch(
        flightNumber: 0, // Not available in GraphQL
        missionName: json['mission_name']?.toString() ?? 'Unknown Mission',
        missionId: [], // Not available in GraphQL
        launchYear: _extractYear(json['launch_date_utc']),
        launchDateUnix: json['launch_date_unix']?.toInt() ?? 0,
        launchDateUtc: json['launch_date_utc']?.toString() ?? '',
        launchDateLocal: json['launch_date_utc']?.toString() ?? '', // Use UTC as fallback
        isTentative: false, // Not available in GraphQL
        tentativeMaxPrecision: null,
        launchSuccess: json['launch_success'],
        launchFailureDetails: null,
        upcoming: json['upcoming'] ?? false,
        details: json['details']?.toString(),
        rocket: LaunchRocket.fromJson(json['rocket'] ?? {}),
        launchSite: null, // Not available in current GraphQL query
        links: LaunchLinks.fromJson({}), // Not available in current GraphQL query
        staticFireDateUtc: null,
        staticFireDateUnix: null,
        timeline: null,
        crew: [],
      );
    }
    
    // Handle REST API format (original implementation)
    return Launch(
      flightNumber: json['flight_number']?.toInt() ?? 0,
      missionName: json['mission_name']?.toString() ?? 'Unknown Mission',
      missionId: json['mission_id'] != null 
          ? List<String>.from(json['mission_id'].map((x) => x.toString()))
          : [],
      launchYear: json['launch_year']?.toString() ?? '',
      launchDateUnix: json['launch_date_unix']?.toInt() ?? 0,
      launchDateUtc: json['launch_date_utc']?.toString() ?? '',
      launchDateLocal: json['launch_date_local']?.toString() ?? '',
      isTentative: json['is_tentative'] ?? false,
      tentativeMaxPrecision: json['tentative_max_precision']?.toString(),
      launchSuccess: json['launch_success'],
      launchFailureDetails: json['launch_failure_details'],
      upcoming: json['upcoming'] ?? false,
      details: json['details']?.toString(),
      rocket: LaunchRocket.fromJson(json['rocket'] ?? {}),
      launchSite: json['launch_site'] != null ? LaunchSite.fromJson(json['launch_site']) : null,
      links: LaunchLinks.fromJson(json['links'] ?? {}),
      staticFireDateUtc: json['static_fire_date_utc']?.toString(),
      staticFireDateUnix: json['static_fire_date_unix']?.toInt(),
      timeline: json['timeline'],
      crew: json['crew'] != null 
          ? List<String>.from(json['crew'].map((x) => x.toString()))
          : [],
    );
  }

  /// Helper method to extract year from date string
  static String _extractYear(String? dateString) {
    if (dateString == null) return '';
    try {
      return DateTime.parse(dateString).year.toString();
    } catch (e) {
      return '';
    }
  }

  /// Converts Launch instance to JSON format
  Map<String, dynamic> toJson() {
    return {
      'flight_number': flightNumber,
      'mission_name': missionName,
      'mission_id': missionId,
      'launch_year': launchYear,
      'launch_date_unix': launchDateUnix,
      'launch_date_utc': launchDateUtc,
      'launch_date_local': launchDateLocal,
      'is_tentative': isTentative,
      'tentative_max_precision': tentativeMaxPrecision,
      'launch_success': launchSuccess,
      'launch_failure_details': launchFailureDetails,
      'upcoming': upcoming,
      'details': details,
      'rocket': rocket.toJson(),
      'launch_site': launchSite?.toJson(),
      'links': links.toJson(),
      'static_fire_date_utc': staticFireDateUtc,
      'static_fire_date_unix': staticFireDateUnix,
      'timeline': timeline,
      'crew': crew,
    };
  }

  /// Creates a Launch instance from JSON string
  factory Launch.fromRawJson(String str) => Launch.fromJson(json.decode(str));

  /// Converts Launch instance to JSON string
  String toRawJson() => json.encode(toJson());

  /// Creates a copy of this Launch with optionally updated fields
  Launch copyWith({
    int? flightNumber,
    String? missionName,
    List<String>? missionId,
    String? launchYear,
    int? launchDateUnix,
    String? launchDateUtc,
    String? launchDateLocal,
    bool? isTentative,
    String? tentativeMaxPrecision,
    bool? launchSuccess,
    Map<String, dynamic>? launchFailureDetails,
    bool? upcoming,
    String? details,
    LaunchRocket? rocket,
    LaunchSite? launchSite,
    LaunchLinks? links,
    String? staticFireDateUtc,
    int? staticFireDateUnix,
    Map<String, dynamic>? timeline,
    List<String>? crew,
  }) {
    return Launch(
      flightNumber: flightNumber ?? this.flightNumber,
      missionName: missionName ?? this.missionName,
      missionId: missionId ?? this.missionId,
      launchYear: launchYear ?? this.launchYear,
      launchDateUnix: launchDateUnix ?? this.launchDateUnix,
      launchDateUtc: launchDateUtc ?? this.launchDateUtc,
      launchDateLocal: launchDateLocal ?? this.launchDateLocal,
      isTentative: isTentative ?? this.isTentative,
      tentativeMaxPrecision: tentativeMaxPrecision ?? this.tentativeMaxPrecision,
      launchSuccess: launchSuccess ?? this.launchSuccess,
      launchFailureDetails: launchFailureDetails ?? this.launchFailureDetails,
      upcoming: upcoming ?? this.upcoming,
      details: details ?? this.details,
      rocket: rocket ?? this.rocket,
      launchSite: launchSite ?? this.launchSite,
      links: links ?? this.links,
      staticFireDateUtc: staticFireDateUtc ?? this.staticFireDateUtc,
      staticFireDateUnix: staticFireDateUnix ?? this.staticFireDateUnix,
      timeline: timeline ?? this.timeline,
      crew: crew ?? this.crew,
    );
  }

  /// Returns launch status as a readable string
  String get launchStatus {
    if (upcoming) return 'Upcoming';
    if (launchSuccess == null) return 'Unknown';
    return launchSuccess! ? 'Success' : 'Failed';
  }

  /// Returns launch date as DateTime object
  DateTime get launchDate => DateTime.fromMillisecondsSinceEpoch(launchDateUnix * 1000);

  /// Returns formatted launch date string
  String get formattedLaunchDate {
    final date = launchDate;
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Returns formatted launch time string
  String get formattedLaunchTime {
    final date = launchDate;
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Returns true if launch has mission patch
  bool get hasMissionPatch => links.missionPatch != null || links.missionPatchSmall != null;

  /// Returns true if launch has video content
  bool get hasVideo => links.videoLink != null || links.youtubeId != null;

  /// Returns true if launch has images
  bool get hasImages => links.flickrImages.isNotEmpty;

  /// Returns true if this is a crewed mission
  bool get isCrewed => crew.isNotEmpty;

  /// Returns launch outcome color for UI
  String get outcomeColor {
    if (upcoming) return 'upcoming';
    if (launchSuccess == null) return 'unknown';
    return launchSuccess! ? 'success' : 'failed';
  }

  /// Returns days until launch (negative if past)
  int get daysUntilLaunch {
    final now = DateTime.now();
    final launch = launchDate;
    return launch.difference(now).inDays;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Launch && other.flightNumber == flightNumber;
  }

  @override
  int get hashCode => flightNumber.hashCode;

  @override
  String toString() {
    return 'Launch(flightNumber: $flightNumber, missionName: $missionName, status: $launchStatus)';
  }
}
