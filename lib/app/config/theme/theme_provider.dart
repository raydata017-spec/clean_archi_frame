import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/shared_pref_service.dart';
import '../flavors/flavor_config_provider.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeController extends _$ThemeController {
  @override
  ThemeMode build() {
    final modeStr = ref.watch(sharedPrefServiceProvider).getThemeMode();
    final defaultMode = ref.watch(appConfigProvider).defaultThemeMode;

    if (modeStr == null) {
      return defaultMode;
    }

    switch (modeStr) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return defaultMode;
    }
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    String modeStr = 'system';
    if (mode == ThemeMode.light) {
      modeStr = 'light';
    } else if (mode == ThemeMode.dark) {
      modeStr = 'dark';
    }
    ref.read(sharedPrefServiceProvider).saveThemeMode(modeStr);
  }

  void toggleTheme() {
    if (state == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }
}
