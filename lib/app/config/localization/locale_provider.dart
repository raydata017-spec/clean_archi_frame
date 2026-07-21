import 'dart:ui';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/shared_pref_service.dart';
import '../flavors/flavor_config_provider.dart';
import 'generated/translations.g.dart';

part 'locale_provider.g.dart';

enum AppLocaleMode {
  system,
  english,
  burmese,
}

@riverpod
class LocaleController extends _$LocaleController {
  @override
  AppLocaleMode build() {
    final savedLocale = ref.watch(sharedPrefServiceProvider).getLocale();
    final defaultMode = ref.watch(appConfigProvider).defaultLocaleMode;
    final mode = savedLocale == null ? defaultMode : _parseLocaleMode(savedLocale, fallback: defaultMode);
    _applyLocale(mode);
    return mode;
  }

  void changeLocale(AppLocaleMode mode) {
    _applyLocale(mode);
    state = mode;
    ref.read(sharedPrefServiceProvider).saveLocale(mode.name);
  }

  AppLocaleMode _parseLocaleMode(String? value, {AppLocaleMode fallback = AppLocaleMode.system}) {
    if (value == null) return fallback;
    return AppLocaleMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => fallback,
    );
  }

  void _applyLocale(AppLocaleMode mode) {
    switch (mode) {
      case AppLocaleMode.english:
        LocaleSettings.setLocale(AppLocale.en);
        break;
      case AppLocaleMode.burmese:
        LocaleSettings.setLocale(AppLocale.my);
        break;
      case AppLocaleMode.system:
        final systemLanguageCode = PlatformDispatcher.instance.locale.languageCode;
        if (systemLanguageCode == 'my') {
          LocaleSettings.setLocale(AppLocale.my);
        } else {
          LocaleSettings.setLocale(AppLocale.en);
        }
        break;
    }
  }
}
