import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/utils/extensions/context_extension.dart';
import 'config/localization/generated/translations.g.dart';
import 'config/localization/locale_provider.dart';
import 'config/theme/theme.dart';
import 'config/theme/theme_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme and locale providers to rebuild the app when they change
    final themeMode = ref.watch(themeControllerProvider);
    ref.watch(localeControllerProvider);

    return MaterialApp(
      title: 'BDATA Core Template V1.0.0',
      // Theme Configuration
      themeMode: themeMode,
      theme: lightThemeData,
      darkTheme: darkThemeData,

      // Slang Localization Configuration
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: SafeArea(
            top: false,
            bottom: Platform.isAndroid ? true : false,
            child: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: child ?? const SizedBox(),
            ),
          ),
        );
      },
      home: const DummyHomeScreen(),
    );
  }
}

class DummyHomeScreen extends ConsumerWidget {
  const DummyHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // context.colors (Custom extension)
      backgroundColor: context.colors.customBackground,
      appBar: AppBar(title: const Text('Theme Architecture')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dynamic translation with parameters
            Text(
              t.kDynamic.welcomeMessage(name: 'Kaung Mrat', point: 1500),
            ),
            Text(
              t.kDynamic.inboxCount(n: 10),
            ),
            // -------------------------------------------
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton(
                  // context.colorScheme (Material default)
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colorScheme.primary,
                  ),
                  onPressed: () {
                    ref.read(themeControllerProvider.notifier).toggleTheme();
                  },
                  child: Text(
                    t.setting.changeTheme,
                    style: TextStyle(color: context.colorScheme.onPrimary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final currentLocale = LocaleSettings.currentLocale;
                    final newLocale = currentLocale == AppLocale.en ? AppLocale.my : AppLocale.en;

                    ref.read(localeControllerProvider.notifier).changeLocale(newLocale);
                  },
                  child: Text(
                    t.setting.changeLanguage,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
