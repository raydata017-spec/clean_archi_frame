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
  static const String _tokenKey = 'auth_token';

  // --- Theme ---
  Future<void> saveThemeMode(bool isDark) async {
    await _prefs.setBool(_themeModeKey, isDark);
  }

  bool? getThemeMode() {
    return _prefs.getBool(_themeModeKey);
  }

  // --- Auth Token ---
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> removeToken() async {
    await _prefs.remove(_tokenKey);
  }

  // --- Clear All ---
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
