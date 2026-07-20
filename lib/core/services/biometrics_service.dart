import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

final biometricsServiceProvider = Provider<BiometricsService>((ref) {
  return BiometricsService(LocalAuthentication());
});

class BiometricsService {
  final LocalAuthentication _auth;

  BiometricsService(this._auth);

  /// Checks if the device has the hardware capabilities for biometric authentication.
  Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Checks if the device has active biometrics enrolled and is ready to authenticate.
  Future<bool> canAuthenticate() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Retrieves a list of biometric hardware types enrolled on the device.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (_) {
      return const [];
    }
  }

  /// Triggers the native biometric dialog for authentication.
  Future<bool> authenticate({
    required String reason,
    bool stickyAuth = true,
    bool biometricOnly = true,
  }) async {
    try {
      final isSupported = await isDeviceSupported();
      final hasBiometrics = await canAuthenticate();
      if (!isSupported || !hasBiometrics) return false;

      // local_auth 3.x: options are top-level named params (not AuthenticationOptions).
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: biometricOnly,
        persistAcrossBackgrounding: stickyAuth,
      );
    } on PlatformException catch (_) {
      return false;
    }
  }
}
