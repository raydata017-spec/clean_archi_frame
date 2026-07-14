import 'dart:ui';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/shared_pref_service.dart';
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
    final mode = _parseLocaleMode(savedLocale);
    _applyLocale(mode);
    return mode;
  }

  void changeLocale(AppLocaleMode mode) {
    _applyLocale(mode);
    state = mode;
    ref.read(sharedPrefServiceProvider).saveLocale(mode.name);
  }

  AppLocaleMode _parseLocaleMode(String? value) {
    if (value == null) return AppLocaleMode.system;
    return AppLocaleMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppLocaleMode.system,
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
