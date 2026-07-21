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
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _biometricEnabledKey = 'biometric_enabled';

  // --- Theme ---
  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(_themeModeKey, mode);
  }

  String? getThemeMode() {
    final value = _prefs.get(_themeModeKey);
    if (value is bool) {
      return value ? 'dark' : 'light';
    }
    if (value is String) {
      return value;
    }
    return null;
  }

  // --- Locale ---
  Future<void> saveLocale(String languageCode) async {
    await _prefs.setString(_localeKey, languageCode);
  }

  String? getLocale() {
    return _prefs.getString(_localeKey);
  }

  // --- Auth Token ---
  Future<void> saveAuthToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getAuthToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> deleteAuthToken() async {
    await _prefs.remove(_tokenKey);
  }

  // --- Refresh Token ---
  Future<void> saveRefreshToken(String token) async {
    await _prefs.setString(_refreshTokenKey, token);
  }

  String? getRefreshToken() {
    return _prefs.getString(_refreshTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await _prefs.remove(_refreshTokenKey);
  }

  // --- Biometric Preferred State ---
  Future<void> saveBiometricEnabled(bool enabled) async {
    await _prefs.setBool(_biometricEnabledKey, enabled);
  }

  bool getBiometricEnabled() {
    return _prefs.getBool(_biometricEnabledKey) ?? false;
  }

  // --- Clear All ---
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
