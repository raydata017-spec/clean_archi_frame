import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/config/localization/generated/translations.g.dart';
import '../../app/config/navigation_config.dart';
import '../../core/utils/extensions/dialog_extension.dart';
import '../widgets/app_alert_dialog.dart';

class BranchPopScope extends StatelessWidget {
  final Widget child;

  const BranchPopScope({
    super.key,
    required this.child,
  });

  void _showExitDialog(BuildContext context) {
    context.showAppDialog(
      builder: (context) => AppAlertDialog(
        title: t.common.exitAppTitle,
        content: t.common.exitAppConfirm,
        cancelLabel: t.common.cancel,
        confirmLabel: t.common.exit,
        onCancel: () => context.pop(),
        onConfirm: () {
          NavigationConfig.isExiting = true;
          context.pop();
          SystemNavigator.pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showDrawer = NavigationConfig.mode == NavigationType.drawer ||
        NavigationConfig.mode == NavigationType.both;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        // 1. Check if drawer is open
        if (showDrawer && (NavigationConfig.scaffoldKey.currentState?.isDrawerOpen ?? false)) {
          NavigationConfig.scaffoldKey.currentState?.closeDrawer();
          return;
        }

        // 2. Handle the back key logic for navigation mode.
        final isDrawerOnlyMode = NavigationConfig.mode == NavigationType.drawer;

        if (isDrawerOnlyMode) {
          _showExitDialog(context);
        } else {
          final navigationShell = StatefulNavigationShell.of(context);
          final currentIndex = navigationShell.currentIndex;
          if (currentIndex == 0) {
            _showExitDialog(context);
          } else {
            navigationShell.goBranch(0);
          }
        }
      },
      child: child,
    );
  }
}
