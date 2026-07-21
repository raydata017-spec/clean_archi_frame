import 'package:flutter/material.dart';
import '../assets.dart';
import '../colors.dart';
import '../localization/locale_provider.dart';
import 'app_flavor.dart';

class AppConfig {
  final String appName;
  final AppFlavor flavor;
  final String apiBaseUrl;
  final Color primaryColor;
  final Color secondaryColor;
  final String appLogoAsset;
  final ThemeMode defaultThemeMode;
  final AppLocaleMode defaultLocaleMode;
  final Map<String, bool> featureFlags;

  const AppConfig({
    required this.appName,
    required this.flavor,
    required this.apiBaseUrl,
    required this.primaryColor,
    required this.secondaryColor,
    required this.appLogoAsset,
    this.defaultThemeMode = ThemeMode.system,
    this.defaultLocaleMode = AppLocaleMode.system,
    this.featureFlags = const {},
  });

  bool isFeatureEnabled(String featureKey) {
    return featureFlags[featureKey] ?? false;
  }

  /// Helper to resolve AppConfig by AppFlavor enum
  static AppConfig fromFlavor(AppFlavor flavor) {
    switch (flavor) {
      case AppFlavor.clientA:
        return clientA;
      case AppFlavor.clientB:
        return clientB;
      case AppFlavor.defaultApp:
        return defaultApp;
    }
  }

  // --- Client Configurations ---

  static const AppConfig defaultApp = AppConfig(
    appName: 'BDATA Core Template V1.0.0',
    flavor: AppFlavor.defaultApp,
    apiBaseUrl: 'https://api.default.example.com',
    primaryColor: AppColors.primary,
    secondaryColor: AppColors.secondary,
    appLogoAsset: Assets.updateRocketIcon,
    defaultThemeMode: ThemeMode.system,
    defaultLocaleMode: AppLocaleMode.system,
    featureFlags: {
      'enableBiometrics': true,
      'enableOfflineSync': true,
      'enableInAppUpdate': true,
    },
  );

  static const AppConfig clientA = AppConfig(
    appName: 'Client A Enterprise',
    flavor: AppFlavor.clientA,
    apiBaseUrl: 'https://api.clienta.example.com',
    primaryColor: Color(0xFF1E3A8A),
    secondaryColor: Color(0xFF0D9488),
    appLogoAsset: Assets.emptyBoxPng,
    defaultThemeMode: ThemeMode.system,
    defaultLocaleMode: AppLocaleMode.system,
    featureFlags: {
      'enableBiometrics': false,
      'enableOfflineSync': false,
      'enableInAppUpdate': false,
    },
  );

  static const AppConfig clientB = AppConfig(
    appName: 'Client B Commerce',
    flavor: AppFlavor.clientB,
    apiBaseUrl: 'https://api.clientb.example.com',
    primaryColor: Color(0xFF4C1D95),
    secondaryColor: Color(0xFFE11D48),
    appLogoAsset: Assets.emptyBoxPng,
    defaultThemeMode: ThemeMode.system,
    defaultLocaleMode: AppLocaleMode.system,
    featureFlags: {
      'enableBiometrics': false,
      'enableOfflineSync': true,
      'enableInAppUpdate': true,
    },
  );
}
