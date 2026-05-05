import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/shared_pref_service.dart';
part 'theme_provider.g.dart';

@riverpod
class ThemeController extends _$ThemeController {
  @override
  ThemeMode build() {
    final isDark = ref.watch(sharedPrefServiceProvider).getThemeMode();

    if (isDark == null) return ThemeMode.system;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    final currentTheme = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = currentTheme;

    ref.read(sharedPrefServiceProvider).saveThemeMode(currentTheme == ThemeMode.dark);
  }
}
