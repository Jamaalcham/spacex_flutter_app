import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'i18n_helper.dart';

// Language codes
const String ENGLISH = 'en';
const String FRANCAIS = 'fr';

// Get translated text using flutter_i18n
String getTranslated(BuildContext context, String key, {Map<String, String>? params}) {
  return I18nHelper.translate(context, key, placeholders: params);
}

// Set locale and notify listeners
Future<void> setLocale(BuildContext context, String languageCode) async {
  await I18nHelper.setLocale(languageCode);
  await FlutterI18n.refresh(context, Locale(languageCode));
}

// Get current locale
Future<Locale> getLocale() async {
  return await I18nHelper.getCurrentLocale();
}

// Get supported locales
List<Locale> getSupportedLocales() {
  return I18nHelper.getSupportedLocales();
}

// Get language display name
String getLanguageName(String languageCode) {
  return I18nHelper.getLanguageName(languageCode);
}
