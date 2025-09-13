import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('fr', ''),
  ];

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    String jsonString = await rootBundle.loadString('lib/lang/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Common translations
  String get appTitle => translate('app_title');
  String get appSubtitle => translate('app_subtitle');
  String get missionStats => translate('mission_stats');
  String get exploreData => translate('explore_data');
  String get totalMissions => translate('total_missions');
  String get activeRockets => translate('active_rockets');
  String get successRate => translate('success_rate');
  String get upcomingLaunches => translate('upcoming_launches');
  String get exploreSections => translate('explore_sections');
  String get discoverSpacex => translate('discover_spacex');
  String get missions => translate('missions');
  String get exploreMissions => translate('explore_missions');
  String get rockets => translate('rockets');
  String get discoverRockets => translate('discover_rockets');
  String get launches => translate('launches');
  String get trackLaunches => translate('track_launches');
  String get settings => translate('settings');
  String get customizeApp => translate('customize_app');
  String get lightMode => translate('light_mode');
  String get darkMode => translate('dark_mode');
  String get toggleTheme => translate('toggle_theme');
  String get changeLanguage => translate('change_language');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
