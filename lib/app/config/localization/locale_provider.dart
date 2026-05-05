import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/shared_pref_service.dart';
import 'generated/translations.g.dart';

part 'locale_provider.g.dart';

@riverpod
class LocaleController extends _$LocaleController {
  @override
  AppLocale build() {
    final savedLocale = ref.watch(sharedPrefServiceProvider).getLocale();

    if (savedLocale != null) {
      final locale = AppLocaleUtils.parse(savedLocale);
      LocaleSettings.setLocale(locale);
      return locale;
    }
    LocaleSettings.useDeviceLocale();
    return LocaleSettings.currentLocale;
  }

  void changeLocale(AppLocale newLocale) {
    LocaleSettings.setLocale(newLocale);

    state = newLocale;

    ref.read(sharedPrefServiceProvider).saveLocale(newLocale.languageCode);
  }
}
