import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/flavors/flavor_config_provider.dart';
import 'config/localization/generated/translations.g.dart';
import 'config/localization/locale_provider.dart';
import 'config/theme/theme.dart';
import 'config/theme/theme_provider.dart';
import 'router/app_router.dart';

import 'router/main_back_button_dispatcher.dart';
import 'package:cupertino_back_gesture/cupertino_back_gesture.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

import '../core/services/connectivity_service.dart';
import '../core/services/toast_service.dart';
import '../core/di/profile_di.dart';

final mainBackButtonDispatcherProvider = Provider<MainBackButtonDispatcher>((ref) {
  final goRouter = ref.watch(appRouterProvider);
  return MainBackButtonDispatcher(goRouter);
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch flavor config provider
    final appConfig = ref.watch(appConfigProvider);

    // Watch theme and locale providers to rebuild the app when they change
    final themeMode = ref.watch(themeControllerProvider);
    ref.watch(localeControllerProvider);

    // Register offline profile processors (create_profile / update_profile)
    ref.watch(profileOfflineBootstrapProvider);

    // Watch the router provider to get the current router configuration
    final goRouter = ref.watch(appRouterProvider);
    final backButtonDispatcher = ref.watch(mainBackButtonDispatcherProvider);

    // Listen to connectivity changes to show global toasts
    ref.listen<AsyncValue<bool>>(connectivityStreamProvider, (previous, next) {
      final isConnected = next.value;
      if (isConnected == null) return;

      final wasConnected = previous?.value;

      if (!isConnected) {
        // Lost internet connection (or started offline)
        Future.delayed(const Duration(milliseconds: 500), () {
          ToastService.showWarningToast(message: t.common.noInternet);
        });
      } else if (wasConnected == false && isConnected) {
        // Internet connection restored
        ToastService.showInfoToast(message: t.common.internetRestored);
      }
    });

    return BackGestureWidthTheme(
      backGestureWidth: BackGestureWidth.fraction(0.5),
      child: StyledToast(
        child: MaterialApp.router(
          title: appConfig.appName,
          // Dynamic Flavor Theme Configuration
          themeMode: themeMode,
          theme: buildLightTheme(config: appConfig),
          darkTheme: buildDarkTheme(config: appConfig),

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
                bottom: defaultTargetPlatform == TargetPlatform.android,
                child: GestureDetector(
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  child: child ?? const SizedBox(),
                ),
              ),
            );
          },

          routerDelegate: goRouter.routerDelegate,
          routeInformationParser: goRouter.routeInformationParser,
          routeInformationProvider: goRouter.routeInformationProvider,
          backButtonDispatcher: backButtonDispatcher,
        ),
      ),
    );
  }
}
