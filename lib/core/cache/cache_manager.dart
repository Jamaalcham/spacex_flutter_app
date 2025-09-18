import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Base cache manager for handling offline data storage
/// 
/// Provides common functionality for caching API responses locally
/// with expiration times and offline fallback capabilities.
abstract class CacheManager<T> {
  final String cacheKey;
  final Duration cacheDuration;

  CacheManager({
    required this.cacheKey,
    this.cacheDuration = const Duration(hours: 1),
  });

  /// Converts object to JSON for storage
  Map<String, dynamic> toJson(T item);

  /// Converts JSON back to object
  T fromJson(Map<String, dynamic> json);

  /// Converts list of objects to JSON for storage
  List<Map<String, dynamic>> listToJson(List<T> items) {
    return items.map((item) => toJson(item)).toList();
  }

  /// Converts JSON back to list of objects
  List<T> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Caches a single item
  Future<void> cacheItem(T item) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = toJson(item);
    final cacheData = {
      'data': jsonData,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString(cacheKey, jsonEncode(cacheData));
  }

  /// Caches a list of items
  Future<void> cacheList(List<T> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = listToJson(items);
    final cacheData = {
      'data': jsonData,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString(cacheKey, jsonEncode(cacheData));
  }

  /// Retrieves cached item if valid
  Future<T?> getCachedItem() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedString = prefs.getString(cacheKey);
    
    if (cachedString == null) return null;

    try {
      final cacheData = jsonDecode(cachedString) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      
      // Check if cache is still valid
      if (DateTime.now().difference(cacheTime) > cacheDuration) {
        await clearCache();
        return null;
      }

      final data = cacheData['data'] as Map<String, dynamic>;
      return fromJson(data);
    } catch (e) {
      // If there's an error parsing, clear the cache
      await clearCache();
      return null;
    }
  }

  /// Retrieves cached list if valid
  Future<List<T>?> getCachedList() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedString = prefs.getString(cacheKey);
    
    if (cachedString == null) return null;

    try {
      final cacheData = jsonDecode(cachedString) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      
      // Check if cache is still valid
      if (DateTime.now().difference(cacheTime) > cacheDuration) {
        await clearCache();
        return null;
      }

      final data = cacheData['data'] as List<dynamic>;
      return listFromJson(data);
    } catch (e) {
      // If there's an error parsing, clear the cache
      await clearCache();
      return null;
    }
  }

  /// Checks if cached data exists and is valid
  Future<bool> isCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedString = prefs.getString(cacheKey);
    
    if (cachedString == null) return false;

    try {
      final cacheData = jsonDecode(cachedString) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      
      return DateTime.now().difference(cacheTime) <= cacheDuration;
    } catch (e) {
      return false;
    }
  }

  /// Clears cached data
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(cacheKey);
  }

  /// Gets cache timestamp
  Future<DateTime?> getCacheTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedString = prefs.getString(cacheKey);
    
    if (cachedString == null) return null;

    try {
      final cacheData = jsonDecode(cachedString) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      return null;
    }
  }
}
