import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/landpad_entity.dart';

// Cache manager for landpad data with 2-hour cache duration
class LandpadCacheManager {
  static const String _landpadsKey = 'cached_landpads';
  static const String _landpadsTimestampKey = 'cached_landpads_timestamp';
  static const Duration _cacheDuration = Duration(hours: 2); // 2 hours cache

  Future<void> cacheLandpadsJson(List<Map<String, dynamic>> landpadsJson) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(landpadsJson);
      await prefs.setString(_landpadsKey, jsonString);
      await prefs.setInt(_landpadsTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Silently fail cache operations to not break the app
      print('Failed to cache landpads: $e');
    }
  }

  Future<List<LandpadEntity>?> getCachedLandpads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if cache exists and is not expired
      final timestamp = prefs.getInt(_landpadsTimestampKey);
      if (timestamp == null) return null;
      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      
      if (now.difference(cacheTime) > _cacheDuration) {
        // Cache expired, clear it
        await clearCache();
        return null;
      }
      
      final jsonString = prefs.getString(_landpadsKey);
      if (jsonString == null) return null;
      
      final List<dynamic> jsonData = jsonDecode(jsonString);
      return jsonData.map((json) => LandpadEntity.fromJson(json)).toList();
    } catch (e) {
      print('Failed to retrieve cached landpads: $e');
      return null;
    }
  }

  Future<bool> isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_landpadsTimestampKey);
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
      await prefs.remove(_landpadsKey);
      await prefs.remove(_landpadsTimestampKey);
    } catch (e) {
      print('Failed to clear landpad cache: $e');
    }
  }

  Future<int?> getCacheAgeInMinutes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_landpadsTimestampKey);
      if (timestamp == null) return null;
      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      
      return now.difference(cacheTime).inMinutes;
    } catch (e) {
      return null;
    }
  }
}
