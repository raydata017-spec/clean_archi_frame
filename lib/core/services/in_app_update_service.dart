import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app/config/in_app_update_config.dart';
import '../../app/router/route_names.dart';
import '../../shared/widgets/app_alert_dialog.dart';
import 'toast_service.dart';

class InAppUpdateService {
  static ValueNotifier<bool> isDownloading = ValueNotifier(false);
  static ValueNotifier<String> updateProgress = ValueNotifier('0');

  static InAppUpdateConfig get _config => InAppUpdateConfig.current;

  Future<bool> checkRemoteConfigForUpdate({required BuildContext context}) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: _config.fetchTimeout,
          minimumFetchInterval: _config.minimumFetchInterval,
        ),
      );
      await remoteConfig.fetchAndActivate();

      final apkLink = remoteConfig.getString(_config.remoteApkLinkKey);
      final remoteVersionRaw = remoteConfig.getString(_config.remoteVersionKey);
      final whatsNew = remoteConfig.getString(_config.remoteWhatsNewKey);

      // Local combined version string like `1.0.0(1)` if build available.
      final localCombined = buildNumber.isNotEmpty ? '$version($buildNumber)' : version;

      if (isUpdateAvailable(localCombined, remoteVersionRaw) && apkLink.isNotEmpty) {
        if (!context.mounted) return false;
        await showUpdateDialog(
          context,
          whatsNew: whatsNew.isNotEmpty ? whatsNew : 'A new update is available.',
          apkLink: apkLink,
          updateVersion: remoteVersionRaw,
          currentVersion: localCombined,
        );
        return true; // Stop standard app redirection navigation
      }
    } catch (e, _) {
      debugPrint('Error checking remote config: $e');
    }
    return false;
  }

  /// Extracts the numeric build number from strings such as:
  /// - `1.0.0(12)` -> 12
  /// - `12` -> 12
  /// - `1.0.0` -> 0
  static int extractBuildNumber(String versionString) {
    final s = versionString.trim();

    // Match number inside parentheses: `1.0.0(12)`
    final parenMatch = RegExp(r'\((\d+)\)').firstMatch(s);
    if (parenMatch != null) {
      return int.tryParse(parenMatch.group(1) ?? '') ?? 0;
    }

    // Match number after plus or dash: `1.0.0+12` or `1.0.0-12`
    final separatorMatch = RegExp(r'[+-](\d+)$').firstMatch(s);
    if (separatorMatch != null) {
      return int.tryParse(separatorMatch.group(1) ?? '') ?? 0;
    }

    // If the whole string is just digits, return it (e.g. `12`)
    if (RegExp(r'^\d+$').hasMatch(s)) {
      return int.tryParse(s) ?? 0;
    }

    return 0;
  }

  /// Extracts the semantic version portion from a string like `1.0.0(1)` -> `1.0.0`.
  static String extractSemanticVersion(String versionString) {
    final s = versionString.trim();
    final match = RegExp(r'^([0-9]+(?:\.[0-9]+)*)').firstMatch(s);
    return match?.group(1) ?? s;
  }

  /// Returns true if the remote version represents a newer version (either semantic or build number).
  static bool isUpdateAvailable(String local, String remote) {
    final localSem = extractSemanticVersion(local);
    final remoteSem = extractSemanticVersion(remote);

    if (localSem != remoteSem) {
      final localParts = localSem.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final remoteParts = remoteSem.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      final n = localParts.length > remoteParts.length ? localParts.length : remoteParts.length;
      for (int i = 0; i < n; i++) {
        final l = i < localParts.length ? localParts[i] : 0;
        final r = i < remoteParts.length ? remoteParts[i] : 0;
        if (r > l) return true;
        if (l > r) return false;
      }
    }

    return extractBuildNumber(remote) > extractBuildNumber(local);
  }

  static Future<void> showUpdateDialog(
    BuildContext context, {
    required String whatsNew,
    required String apkLink,
    required String updateVersion,
    required String currentVersion,
  }) async {
    final colorScheme = Theme.of(context).colorScheme;

    final shouldUpdate = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AppAlertDialog(
          title: 'New Update',
          content: whatsNew,
          contentAlign: TextAlign.left,
          confirmLabel: 'Update',
          confirmColor: colorScheme.primary,
          onConfirm: () {
            dialogContext.pop(true);
          },
        );
      },
    );

    if (shouldUpdate == true) {
      try {
        if (!context.mounted) return;
        context.go(
          RouteNames.appUpdatePath,
          extra: {
            'apkLink': apkLink,
            'updateVersion': updateVersion,
            'currentVersion': currentVersion,
            'whatsNew': whatsNew,
          },
        );
      } catch (e, _) {
        debugPrint('Navigation to app update route failed: $e');
      }
    }
  }

  static Future<void> downloadAndInstall({required String latestApkUrl}) async {
    if (Platform.isAndroid) {
      var status = await Permission.requestInstallPackages.status;

      if (!status.isGranted) {
        status = await Permission.requestInstallPackages.request();

        if (!status.isGranted) {
          ToastService.showErrorToast(
            errorMessage: 'Permission to install packages is required to update the app. Please grant the permission in settings and try again.',
          );
          await Future.delayed(const Duration(seconds: 2));
          await openAppSettings();
          return;
        }
      }
    }

    try {
      isDownloading.value = true;
      OtaUpdate()
          .execute(
            latestApkUrl,
            destinationFilename: _config.destinationFilename,
            usePackageInstaller: false,
            androidProviderAuthority: _config.androidProviderAuthority,
          )
          .listen(
            (OtaEvent event) {
              switch (event.status) {
                case OtaStatus.DOWNLOADING:
                  updateProgress.value = event.value!;
                  break;
                case OtaStatus.INSTALLING:
                  isDownloading.value = false;
                  debugPrint('Installing update...');
                  break;
                case OtaStatus.ALREADY_RUNNING_ERROR:
                  debugPrint('OTA update already running');
                  break;
                case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
                  ToastService.showErrorToast(errorMessage: 'Permission not granted for update');
                  isDownloading.value = false;
                  break;
                case OtaStatus.INTERNAL_ERROR:
                  ToastService.showErrorToast(errorMessage: 'Internal error during update');
                  isDownloading.value = false;
                  break;
                case OtaStatus.DOWNLOAD_ERROR:
                  ToastService.showErrorToast(errorMessage: 'Download failed');
                  isDownloading.value = false;
                  break;
                case OtaStatus.CHECKSUM_ERROR:
                  ToastService.showErrorToast(errorMessage: 'Checksum error. File might be corrupted.');
                  isDownloading.value = false;
                  break;
                case OtaStatus.INSTALLATION_ERROR:
                  ToastService.showErrorToast(errorMessage: 'Installation failed');
                  isDownloading.value = false;
                  break;
                case OtaStatus.INSTALLATION_DONE:
                  debugPrint('Installation done');
                  break;
                case OtaStatus.CANCELED:
                  debugPrint('Update canceled by user');
                  isDownloading.value = false;
                  break;
              }
            },
          );
    } catch (e) {
      debugPrint('Error during OTA update: $e');
      isDownloading.value = false;
      ToastService.showErrorToast(errorMessage: 'Error during update');
    }
  }
}

