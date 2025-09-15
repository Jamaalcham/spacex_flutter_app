import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

import '../../data/models/language_model.dart';

class LanguageProvider extends ChangeNotifier {
  final String key = 'languageCode';
  late LanguageModel _selectedLanguage;
  final List<LanguageModel> _languages = LanguageModel.languages();
  bool _isInitialized = false;

  LanguageModel get currentLanguage => _selectedLanguage;
  List<LanguageModel> get languages => _languages;
  bool get isInitialized => _isInitialized;
  
  String get currentLanguageName => _selectedLanguage.name;

  LanguageProvider() {
    _selectedLanguage = _languages.first;
  }

  Future<void> initializeLanguage() async {
    if (!_isInitialized) {
      await _loadSavedLanguage();
      _isInitialized = true;
    }
  }

  bool _isSupportedLanguage(String languageCode) {
    return _languages.any(
      (lang) => lang.languageCode.toLowerCase() == languageCode.toLowerCase(),
    );
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // First try to load saved preference
      String? savedLanguageCode = prefs.getString(key);

      String deviceLocale;
      try {
        deviceLocale =
            ui.PlatformDispatcher.instance.locale.languageCode.toLowerCase();
      } catch (e) {
        deviceLocale = 'en';
      }

      String languageCode;
      if (savedLanguageCode != null &&
          _isSupportedLanguage(savedLanguageCode)) {
        // Use saved preference if it exists and is supported
        languageCode = savedLanguageCode;
      } else if (_isSupportedLanguage(deviceLocale)) {
        // Use device locale if supported
        languageCode = deviceLocale;
      } else {
        // Fallback to English
        languageCode = 'en';
      }

      _selectedLanguage = _languages.firstWhere(
        (element) => element.languageCode.toLowerCase() == languageCode,
        orElse: () => _languages.first,
      );

      notifyListeners();
    } catch (e) {
      _selectedLanguage = _languages.first;
      notifyListeners();
    }
  }

  Locale get locale {
    return Locale(
      _selectedLanguage.languageCode,
      _selectedLanguage.countryCode,
    );
  }

  Future<void> setLanguage(dynamic language) async {
    try {
      String languageCode;
      if (language is Locale) {
        languageCode = language.languageCode.toLowerCase();
      } else if (language is String) {
        languageCode = language.toLowerCase();
      } else {
        return;
      }

      final selectedLanguage = _languages.firstWhere(
        (element) => element.languageCode.toLowerCase() == languageCode,
        orElse: () => _languages.first,
      );

      _selectedLanguage = selectedLanguage;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, languageCode);

      notifyListeners();
    } catch (e) {
      debugPrint('Error setting language: $e');
    }
  }

  void setLanguageWithoutLocaleChange(String languageCode) {
    try {
      languageCode = languageCode.toLowerCase();

      final language = _languages.firstWhere(
        (element) => element.languageCode.toLowerCase() == languageCode,
        orElse: () => _languages.first,
      );

      _selectedLanguage = language;
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting language without locale change: $e');
    }
  }

  /// Toggle between available languages
  Future<void> toggleLanguage() async {
    final currentIndex = _languages.indexOf(_selectedLanguage);
    final nextIndex = (currentIndex + 1) % _languages.length;
    final nextLanguage = _languages[nextIndex];
    
    _selectedLanguage = nextLanguage;
    await _saveLanguage(nextLanguage.languageCode);
    
    notifyListeners();
  }

  Future<void> _saveLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, languageCode);
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }

  // Static callback to update app locale
  static void Function(Locale)? _localeCallback;
  
  static void setLocaleCallback(void Function(Locale) callback) {
    _localeCallback = callback;
  }
  
  void _updateAppLocale(Locale locale) {
    _localeCallback?.call(locale);
  }
}

// Global reference to the app for locale changes
class SpaceXApp {
  static void setLocale(BuildContext context, Locale newLocale) {
    // This will be handled by the main app widget
  }
}
