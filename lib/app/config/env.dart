import 'flavors/app_config.dart';
import 'flavors/app_flavor.dart';

/// Environment and White-Label configuration helper.
class Env {
  Env._();

  static AppConfig _config = AppConfig.defaultApp;

  /// Initialize Environment with specified White-Label configuration.
  static void init(AppConfig config) {
    _config = config;
  }

  /// Get current AppConfig
  static AppConfig get config => _config;

  /// Active App Name
  static String get appName => _config.appName;

  /// Active App Flavor
  static AppFlavor get flavor => _config.flavor;

  /// Active API Base URL
  static String get apiBaseUrl => _config.apiBaseUrl;

  /// Check feature flag status
  static bool isFeatureEnabled(String featureKey) => _config.isFeatureEnabled(featureKey);
}
