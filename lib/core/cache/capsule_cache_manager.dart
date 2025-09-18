import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/capsule_entity.dart';

// Cache manager for capsule data with 2-hour cache duration
class CapsuleCacheManager {
  static final CapsuleCacheManager _instance = CapsuleCacheManager._internal();
  factory CapsuleCacheManager() => _instance;
  
  CapsuleCacheManager._internal();

  static const String _capsulesKey = 'capsules_cache';
  static const Duration _cacheDuration = Duration(hours: 2);

  Future<void> cacheCapsulesJson(List<Map<String, dynamic>> capsulesJson) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'data': capsulesJson,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString(_capsulesKey, jsonEncode(cacheData));
  }

  Future<List<CapsuleEntity>?> getCachedCapsules() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedString = prefs.getString(_capsulesKey);
    
    if (cachedString == null) return null;

    try {
      final cacheData = jsonDecode(cachedString) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      
      if (DateTime.now().difference(cacheTime) > _cacheDuration) {
        await clearCache();
        return null;
      }

      final data = cacheData['data'] as List<dynamic>;
      return data.map((json) => CapsuleEntity.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      await clearCache();
      return null;
    }
  }

  Future<bool> isCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedString = prefs.getString(_capsulesKey);
    
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
    await prefs.remove(_capsulesKey);
  }
}
