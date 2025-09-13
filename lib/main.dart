import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/utils/app_theme.dart';
import 'core/utils/localization/spacex_localization.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/language_provider.dart';
import 'presentation/providers/mission_provider.dart';
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
  Locale _locale = const Locale('en', 'US');
  late LanguageProvider _languageProvider;

  @override
  void initState() {
    super.initState();
    _languageProvider = LanguageProvider();
    _initializeLanguage();
    
    // Set up locale callback for language changes
    LanguageProvider.setLocaleCallback((newLocale) {
      if (mounted) {
        setState(() {
          _locale = newLocale;
        });
      }
    });
  }

  Future<void> _initializeLanguage() async {
    await _languageProvider.initializeLanguage();
    if (mounted) {
      setState(() {
        _locale = _languageProvider.locale;
      });
    }
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => _languageProvider),
        ChangeNotifierProvider(create: (_) => MissionProvider()),
        ChangeNotifierProvider(create: (_) => RocketProvider()),
        ChangeNotifierProvider(create: (_) => LaunchProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          // Update locale when language provider changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_locale != languageProvider.locale) {
              setState(() {
                _locale = languageProvider.locale;
              });
            }
          });
          
          return Sizer(
            builder: (context, orientation, deviceType) {
              return GetMaterialApp(
                title: 'SpaceX Flutter App',
                debugShowCheckedModeBanner: false,
                theme: themeProvider.lightTheme,
                darkTheme: themeProvider.darkTheme,
                themeMode: themeProvider.themeMode,
                locale: languageProvider.locale, // Use provider's locale directly
                localizationsDelegates: const [
                  SpaceXLocalization.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en', 'US'),
                  Locale('fr', 'FR'),
                ],
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
