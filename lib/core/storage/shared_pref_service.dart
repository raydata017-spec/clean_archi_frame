import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// This provider will be overridden in main.dart to provide the actual SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main()');
});

final sharedPrefServiceProvider = Provider<SharedPrefService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharedPrefService(prefs);
});

class SharedPrefService {
  final SharedPreferences _prefs;

  SharedPrefService(this._prefs);

  // --- Keys ---
  static const String _themeModeKey = 'app_theme_mode';
  static const String _localeKey = 'app_locale';

  // --- Theme ---
  Future<void> saveThemeMode(bool isDark) async {
    await _prefs.setBool(_themeModeKey, isDark);
  }

  bool? getThemeMode() {
    return _prefs.getBool(_themeModeKey);
  }

  // --- Locale ---
  Future<void> saveLocale(String languageCode) async {
    await _prefs.setString(_localeKey, languageCode);
  }

  String? getLocale() {
    return _prefs.getString(_localeKey);
  }

  // --- Clear All ---
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
