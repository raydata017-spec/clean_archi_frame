import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/helpers/permission_helper.dart';

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

class PermissionService {
  /// General method to request any permission
  Future<bool> requestPermission(
    ph.Permission permission, {
    String? permissionName,
    AppSettingsType settingsType = AppSettingsType.settings,
  }) async {
    return await PermissionHelper.requestPermission(
      permission: permission,
      permissionName: permissionName ?? permission.toString().split('.').last,
      permissionService: this,
      settingsType: settingsType,
    );
  }

  /// Request multiple permissions at once
  Future<Map<ph.Permission, ph.PermissionStatus>> requestMultiplePermissions(
    List<ph.Permission> permissions,
  ) async {
    return await PermissionHelper.requestMultiplePermissions(permissions).then((_) async {
      final statuses = <ph.Permission, ph.PermissionStatus>{};
      for (final p in permissions) {
        statuses[p] = await p.status;
      }
      return statuses;
    });
  }

  /// Example - Method to request Location permission
  Future<bool> requestLocationPermission() async {
    return await requestPermission(
      ph.Permission.location,
      permissionName: 'Location',
      settingsType: AppSettingsType.settings,
    );
  }

  /// Example - Method to request Camera permission
  Future<bool> requestCameraPermission() async {
    return await requestPermission(
      ph.Permission.camera,
      permissionName: 'Camera',
      settingsType: AppSettingsType.settings,
    );
  }

  /// Method to open app settings
  void openAppSettings(AppSettingsType type) {
    AppSettings.openAppSettings(asAnotherTask: true, type: type);
  }
}
