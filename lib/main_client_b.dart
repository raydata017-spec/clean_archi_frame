import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/config/env.dart';
import 'app/config/flavors/app_config.dart';
import 'app/config/flavors/flavor_config_provider.dart';
import 'app/config/localization/generated/translations.g.dart';
import 'core/storage/shared_pref_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Client B Flavor Config
  Env.init(AppConfig.clientB);

  LocaleSettings.useDeviceLocale();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(AppConfig.clientB),
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: TranslationProvider(
        child: const MyApp(),
      ),
    ),
  );
}
