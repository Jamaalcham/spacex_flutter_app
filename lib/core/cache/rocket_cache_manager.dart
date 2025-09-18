import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/rocket_entity.dart';

// Cache manager for rocket data with 2-hour cache duration
class RocketCacheManager {
  static final RocketCacheManager _instance = RocketCacheManager._internal();
  factory RocketCacheManager() => _instance;
  
  RocketCacheManager._internal();

  static const String _rocketsKey = 'rockets_cache';
  static const Duration _cacheDuration = Duration(hours: 2);

  Future<void> cacheRocketsJson(List<Map<String, dynamic>> rocketsJson) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'data': rocketsJson,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString(_rocketsKey, jsonEncode(cacheData));
  }

  Future<List<RocketEntity>?> getCachedRockets() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedString = prefs.getString(_rocketsKey);
    
    if (cachedString == null) return null;

    try {
      final cacheData = jsonDecode(cachedString) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      
      // Check if cache is still valid
      if (DateTime.now().difference(cacheTime) > _cacheDuration) {
        await clearCache();
        return null;
      }

      final data = cacheData['data'] as List<dynamic>;
      return data.map((json) => RocketEntity.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      // If there's an error parsing, clear the cache
      await clearCache();
      return null;
    }
  }

  /// Caches a single rocket by ID
  Future<void> cacheRocketById(String id, Map<String, dynamic> rocketJson) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'rocket_$id';
    final cacheData = {
      'data': rocketJson,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString(cacheKey, jsonEncode(cacheData));
  }

  /// Gets cached rocket by ID
  Future<RocketEntity?> getCachedRocketById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'rocket_$id';
    final cachedString = prefs.getString(cacheKey);
    
    if (cachedString == null) return null;

    try {
      final cacheData = jsonDecode(cachedString) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      
      // Check if cache is still valid
      if (DateTime.now().difference(cacheTime) > _cacheDuration) {
        await prefs.remove(cacheKey);
        return null;
      }

      final data = cacheData['data'] as Map<String, dynamic>;
      return RocketEntity.fromJson(data);
    } catch (e) {
      // If there's an error parsing, clear the cache
      await prefs.remove(cacheKey);
      return null;
    }
  }

  Future<bool> isCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedString = prefs.getString(_rocketsKey);
    
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

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
