import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/utils/app_theme.dart';
import 'core/utils/localization/language_constants.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/language_provider.dart';
import 'presentation/providers/capsule_provider.dart';
import 'presentation/providers/rocket_provider.dart';
import 'presentation/providers/launch_provider.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  await SharedPreferences.getInstance();

  runApp(const SpaceXApp());
}

class SpaceXApp extends StatefulWidget {
  const SpaceXApp({super.key});

  @override
  State<SpaceXApp> createState() => _SpaceXAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _SpaceXAppState? state = context.findAncestorStateOfType<_SpaceXAppState>();
    state?.setLocale(newLocale);
  }
}

class _SpaceXAppState extends State<SpaceXApp> {
  late LanguageProvider _languageProvider;

  @override
  void initState() {
    super.initState();
    _languageProvider = LanguageProvider();
    _initializeLanguage();
  }

  Future<void> _initializeLanguage() async {
    await _languageProvider.initializeLanguage();
  }

  void setLocale(Locale locale) {
    _languageProvider.changeLanguage(locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => _languageProvider),
        ChangeNotifierProvider(create: (_) => CapsuleProvider()),
        ChangeNotifierProvider(create: (_) => RocketProvider()),
        ChangeNotifierProvider(create: (_) => LaunchProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return Sizer(
            builder: (context, orientation, deviceType) {
              return GetMaterialApp(
                title: 'SpaceX Flutter App',
                debugShowCheckedModeBanner: false,
                theme: themeProvider.lightTheme,
                darkTheme: themeProvider.darkTheme,
                themeMode: themeProvider.themeMode,
                locale: languageProvider.locale,
                localizationsDelegates: [
                  FlutterI18nDelegate(
                    translationLoader: FileTranslationLoader(
                      useCountryCode: false,
                      fallbackFile: 'en',
                      basePath: 'lib/lang',
                    ),
                  ),
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: getSupportedLocales(),
                home: const SplashScreen(),
                getPages: [
                  GetPage(name: '/', page: () => const SplashScreen()),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
