import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

class PermissionService {
  /// General method to request any permission
  Future<bool> requestPermission(Permission permission) async {
    final status = await permission.request();
    return status.isGranted;
  }

  /// Example - Method to request Location permission
  Future<bool> requestLocationPermission() async {
    return await requestPermission(Permission.location);
  }

  /// Example - Method to request Camera permission
  Future<bool> requestCameraPermission() async {
    return await requestPermission(Permission.camera);
  }

  /// Example - Method to open app settings
  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
