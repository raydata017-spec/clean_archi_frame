import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/localization/generated/translations.g.dart';
import 'config/localization/locale_provider.dart';
import 'config/theme/theme.dart';
import 'config/theme/theme_provider.dart';
import 'router/app_router.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme and locale providers to rebuild the app when they change
    final themeMode = ref.watch(themeControllerProvider);
    ref.watch(localeControllerProvider);

    // Watch the router provider to get the current router configuration
    final goRouter = ref.watch(appRouterProvider);

    return MaterialApp.router(
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

      routerConfig: goRouter,
    );
  }
}
