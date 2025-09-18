import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/launchpad_entity.dart';

// Cache manager for launchpad data with 2-hour cache duration
class LaunchpadCacheManager {
  static const String _launchpadsKey = 'cached_launchpads';
  static const String _launchpadsTimestampKey = 'cached_launchpads_timestamp';
  static const Duration _cacheDuration = Duration(hours: 2); // 2 hours cache

  Future<void> cacheLaunchpadsJson(List<Map<String, dynamic>> launchpadsJson) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(launchpadsJson);
      await prefs.setString(_launchpadsKey, jsonString);
      await prefs.setInt(_launchpadsTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Silently fail cache operations to not break the app
      print('Failed to cache launchpads: $e');
    }
  }

  Future<List<LaunchpadEntity>?> getCachedLaunchpads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if cache exists and is not expired
      final timestamp = prefs.getInt(_launchpadsTimestampKey);
      if (timestamp == null) return null;
      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      
      if (now.difference(cacheTime) > _cacheDuration) {
        // Cache expired, clear it
        await clearCache();
        return null;
      }
      
      final jsonString = prefs.getString(_launchpadsKey);
      if (jsonString == null) return null;
      
      final List<dynamic> jsonData = jsonDecode(jsonString);
      return jsonData.map((json) => LaunchpadEntity.fromJson(json)).toList();
    } catch (e) {
      print('Failed to retrieve cached launchpads: $e');
      return null;
    }
  }

  Future<bool> isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_launchpadsTimestampKey);
      if (timestamp == null) return false;
      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      
      return now.difference(cacheTime) <= _cacheDuration;
    } catch (e) {
      return false;
    }
  }

  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_launchpadsKey);
      await prefs.remove(_launchpadsTimestampKey);
    } catch (e) {
      print('Failed to clear launchpad cache: $e');
    }
  }

  Future<int?> getCacheAgeInMinutes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_launchpadsTimestampKey);
      if (timestamp == null) return null;
      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      
      return now.difference(cacheTime).inMinutes;
    } catch (e) {
      return null;
    }
  }
}
