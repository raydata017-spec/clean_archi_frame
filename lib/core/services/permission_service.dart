import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

class PermissionService {
  /// General method to request any permission
  Future<bool> requestPermission(ph.Permission permission) async {
    final status = await permission.request();
    return status.isGranted;
  }

  /// Request multiple permissions at once
  Future<Map<ph.Permission, ph.PermissionStatus>> requestMultiplePermissions(
    List<ph.Permission> permissions,
  ) async {
    return await permissions.request();
  }

  /// Example - Method to request Location permission
  Future<bool> requestLocationPermission() async {
    return await requestPermission(ph.Permission.location);
  }

  /// Example - Method to request Camera permission
  Future<bool> requestCameraPermission() async {
    return await requestPermission(ph.Permission.camera);
  }

  /// Method to open app settings
  void openAppSettings(AppSettingsType type) {
    AppSettings.openAppSettings(asAnotherTask: true, type: type);
  }
}
