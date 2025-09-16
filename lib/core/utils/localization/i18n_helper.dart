import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:shared_preferences/shared_preferences.dart';

class I18nHelper {
  static const String _languageCodeKey = 'languageCode';
  static const String _defaultLanguage = 'en';
  
  // Supported languages
  static const List<String> supportedLanguages = ['en', 'fr'];
  
  // Get current locale from preferences
  static Future<Locale> getCurrentLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageCodeKey) ?? _defaultLanguage;
      return Locale(languageCode);
    } catch (e) {
      debugPrint('Error getting current locale: $e');
      return const Locale(_defaultLanguage);
    }
  }
  
  // Set locale and save to preferences
  static Future<void> setLocale(String languageCode) async {
    try {
      if (supportedLanguages.contains(languageCode)) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languageCodeKey, languageCode);
      }
    } catch (e) {
      debugPrint('Error setting locale: $e');
    }
  }
  
  // Get translation using flutter_i18n
  static String translate(BuildContext context, String key, {Map<String, String>? placeholders}) {
    try {
      return FlutterI18n.translate(context, key, translationParams: placeholders);
    } catch (e) {
      debugPrint('Translation error for key "$key": $e');
      return key; // Return key as fallback
    }
  }
  
  // Get language name for display
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      default:
        return languageCode.toUpperCase();
    }
  }
  
  // Get all supported locales
  static List<Locale> getSupportedLocales() {
    return supportedLanguages.map((code) => Locale(code)).toList();
  }
}
