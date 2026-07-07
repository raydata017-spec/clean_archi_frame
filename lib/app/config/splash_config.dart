import 'package:flutter/material.dart';

import '../router/route_names.dart';
import '../../core/services/in_app_update_service.dart';

class SplashConfig {
  /// Custom logo widget to render on splash screen.
  final Widget? logoWidget;

  /// Fallback asset path to render SVG or PNG logo if logoWidget is null.
  final String? logoPath;

  /// Custom background color of splash screen.
  /// If null, default colorScheme surface will be used according to corporate constraints.
  final Color? backgroundColor;

  /// Custom loading widget.
  final Widget? loadingIndicator;

  /// Optional version or corporate text to render at the bottom.
  final String? versionText;

  /// Minimum duration to show the splash screen.
  final Duration minDuration;

  /// Async background tasks to run before moving to next route (e.g. database init, api fetch, config fetch).
  final Future<void> Function(BuildContext context)? onInitialize;

  /// Next page route path after splash finishes and initialization succeeds.
  final String nextRoute;

  const SplashConfig({
    this.logoWidget,
    this.logoPath,
    this.backgroundColor,
    this.loadingIndicator,
    this.versionText,
    this.minDuration = const Duration(seconds: 2),
    this.onInitialize,
    this.nextRoute = RouteNames.homePath,
  });

  /// Centralized static instance for current project splash config values.
  /// Modify this variable to customize branding elements and startup flows.
  static final SplashConfig current = SplashConfig(
    logoPath: null, // Set fallback assets SVG or PNG path here, or pass logoWidget
    backgroundColor: null, // If null, auto-resolves to flat light (#FAFAFA) or dark slate (#0F172A)
    versionText: 'Version 1.0.0',
    minDuration: const Duration(seconds: 2),
    onInitialize: (context) async {
      // 1. Run global update checks
      final updateService = InAppUpdateService();
      final hasUpdate = await updateService.checkRemoteConfigForUpdate(context: context);
      if (hasUpdate) {
        // App update dialog will hold execution flow
        return;
      }

      // 2. Perform other initialization tasks if needed (e.g. database setup)
      await Future.delayed(const Duration(milliseconds: 500));
    },
    nextRoute: RouteNames.homePath,
  );
}
