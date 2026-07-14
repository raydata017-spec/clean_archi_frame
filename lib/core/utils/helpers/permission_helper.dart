import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';

import '../../services/permission_service.dart';
import '../../../../app/config/localization/generated/translations.g.dart';
import '../../../../app/router/navigator_keys.dart';
import '../../../../shared/widgets/app_alert_dialog.dart';

class PermissionHelper {
  static Future<bool> requestPermission({
    required Permission permission,
    required String permissionName,
    required PermissionService permissionService,
    AppSettingsType settingsType = AppSettingsType.settings,
  }) async {
    Permission permissionToRequest = permission;

    // Handle Android 13+ (SDK 33) granular storage permissions
    if (Platform.isAndroid && permission == Permission.storage) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        permissionToRequest = Permission.photos;
      }
    }

    final status = await permissionToRequest.request();

    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        return true;
      case PermissionStatus.denied:
        return false;
      case PermissionStatus.permanentlyDenied:
        final ctx = NavigatorKeys.root.currentState?.context;
        if (ctx == null || !ctx.mounted) return false;

        final value = await showDialog<bool>(
          context: ctx,
          barrierDismissible: false,
          builder: (dialogContext) => AppAlertDialog(
            title: t.permission.requiredTitle,
            content: t.permission.disabledMessage(permissionName: permissionName),
            confirmLabel: t.permission.openSettings,
            onConfirm: () => Navigator.of(dialogContext).pop(true),
            cancelLabel: t.permission.cancel,
            onCancel: () => Navigator.of(dialogContext).pop(false),
          ),
        );
        if (value == true) {
          permissionService.openAppSettings(settingsType);
        }
        return false;
      default:
        return false;
    }
  }

  static Future<void> requestMultiplePermissions(
    List<Permission> permissions,
  ) async {
    final statuses = await permissions.request();

    for (final permission in permissions) {
      final status = statuses[permission];
      if (status == null) continue;

      switch (status) {
        case PermissionStatus.granted:
          // Handle granted permission
          break;
        case PermissionStatus.denied:
          // Handle denied permission
          break;
        case PermissionStatus.permanentlyDenied:
          await openAppSettings();
          break;
        default:
          // Handle other cases if necessary (e.g., restricted, limited)
          break;
      }
    }
  }

  static Future<bool> checkPermissionStatus(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }
}
