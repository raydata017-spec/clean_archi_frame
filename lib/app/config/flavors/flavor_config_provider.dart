import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_config.dart';

/// Provider for accessing current White-Label AppConfig across Riverpod dependencies and UI.
final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.defaultApp;
});
