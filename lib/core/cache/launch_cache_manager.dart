import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/launch_entity.dart';

// Cache manager specifically for launch data with 1-hour cache duration
class LaunchCacheManager {
  static final LaunchCacheManager _instance = LaunchCacheManager._internal();
  factory LaunchCacheManager() => _instance;
  
  LaunchCacheManager._internal();

  static const String _launchesKey = 'launches_cache';
  static const String _upcomingKey = 'upcoming_launches_cache';
  static const String _pastKey = 'past_launches_cache';
  static const Duration _cacheDuration = Duration(hours: 1);

  Future<void> cacheLaunchesJson(List<Map<String, dynamic>> launchesJson) async {
    await _cacheJsonData(_launchesKey, launchesJson);
  }

  Future<List<LaunchEntity>?> getCachedLaunches() async {
    final jsonData = await _getCachedJsonData(_launchesKey);
    if (jsonData == null) return null;
    return jsonData.map((json) => LaunchEntity.fromJson(json)).toList();
  }

  Future<void> cacheUpcomingLaunchesJson(List<Map<String, dynamic>> launchesJson) async {
    await _cacheJsonData(_upcomingKey, launchesJson);
  }

  Future<List<LaunchEntity>?> getCachedUpcomingLaunches() async {
    final jsonData = await _getCachedJsonData(_upcomingKey);
    if (jsonData == null) return null;
    return jsonData.map((json) => LaunchEntity.fromJson(json)).toList();
  }

  Future<void> cachePastLaunchesJson(List<Map<String, dynamic>> launchesJson) async {
    await _cacheJsonData(_pastKey, launchesJson);
  }

  Future<List<LaunchEntity>?> getCachedPastLaunches() async {
    final jsonData = await _getCachedJsonData(_pastKey);
    if (jsonData == null) return null;
    return jsonData.map((json) => LaunchEntity.fromJson(json)).toList();
  }

  Future<void> _cacheJsonData(String key, List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString(key, jsonEncode(cacheData));
  }

  Future<List<Map<String, dynamic>>?> _getCachedJsonData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedString = prefs.getString(key);
    
    if (cachedString == null) return null;

    try {
      final cacheData = jsonDecode(cachedString) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      
      if (DateTime.now().difference(cacheTime) > _cacheDuration) {
        await prefs.remove(key);
        return null;
      }

      final data = cacheData['data'] as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      await prefs.remove(key);
      return null;
    }
  }

  Future<bool> isCacheValid(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedString = prefs.getString(key);
    
    if (cachedString == null) return false;

    try {
      final cacheData = jsonDecode(cachedString) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      
      return DateTime.now().difference(cacheTime) <= _cacheDuration;
    } catch (e) {
      return false;
    }
  }

  Future<void> clearAllCaches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_launchesKey);
    await prefs.remove(_upcomingKey);
    await prefs.remove(_pastKey);
  }

  Future<void> clearCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
