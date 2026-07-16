import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/services/biometrics_service.dart';
import '../../../../core/storage/shared_pref_service.dart';

class BiometricEnabledNotifier extends Notifier<bool> {
  late final SharedPrefService _sharedPrefs;

  @override
  bool build() {
    _sharedPrefs = ref.watch(sharedPrefServiceProvider);
    return _sharedPrefs.getBiometricEnabled();
  }

  Future<void> toggleBiometric(bool enabled) async {
    await _sharedPrefs.saveBiometricEnabled(enabled);
    state = enabled;
  }
}

final biometricEnabledProvider =
    NotifierProvider<BiometricEnabledNotifier, bool>(() {
  return BiometricEnabledNotifier();
});

final biometricSupportProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(biometricsServiceProvider);
  final isSupported = await service.isDeviceSupported();
  final canAuth = await service.canAuthenticate();
  return isSupported && canAuth;
});

final activeBiometricTypeProvider = FutureProvider<BiometricType?>((ref) async {
  final service = ref.watch(biometricsServiceProvider);
  final list = await service.getAvailableBiometrics();
  if (list.contains(BiometricType.face)) {
    return BiometricType.face;
  } else if (list.contains(BiometricType.fingerprint)) {
    return BiometricType.fingerprint;
  } else if (list.contains(BiometricType.strong)) {
    return BiometricType.strong;
  } else if (list.contains(BiometricType.weak)) {
    return BiometricType.weak;
  }
  return null;
});
