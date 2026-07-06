import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../app/config/localization/generated/translations.g.dart';
import '../app/config/navigation_config.dart';
import '../app/router/navigator_keys.dart';
import '../core/utils/extensions/bottom_navigation_extension.dart';
import 'widgets/app_alert_dialog.dart';
import 'widgets/bottom_nav/bottom_navigation_item.dart';
import 'widgets/custom_navigation_drawer.dart';

class MainWrapperScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapperScreen({
    super.key,
    required this.navigationShell,
  });

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AppAlertDialog(
        title: t.common.exitAppTitle,
        content: t.common.exitAppConfirm,
        cancelLabel: t.common.cancel,
        confirmLabel: t.common.exit,
        onCancel: () => Navigator.of(context).pop(),
        onConfirm: () {
          Navigator.of(context).pop();
          SystemNavigator.pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showBottomNav = NavigationConfig.mode == NavigationType.bottomNav ||
        NavigationConfig.mode == NavigationType.both;
    final showDrawer = NavigationConfig.mode == NavigationType.drawer ||
        NavigationConfig.mode == NavigationType.both;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        // Check if the nested navigator of the current active branch can pop.
        final activeNavigatorKey = NavigatorKeys.getActiveNavigator(navigationShell.currentIndex);
        if (activeNavigatorKey?.currentState?.canPop() ?? false) {
          activeNavigatorKey!.currentState!.pop();
          return;
        }

        // Handle the back key logic for navigation mode.
        final currentIndex = navigationShell.currentIndex;

        if (currentIndex == 0) {
          _showExitDialog(context);
        } else {
          navigationShell.goBranch(0);
        }
      },
      child: Scaffold(
        key: NavigationConfig.scaffoldKey,
        body: navigationShell,
        drawer: showDrawer ? CustomNavigationDrawer(navigationShell: navigationShell) : null,
        bottomNavigationBar: showBottomNav
            ? context.buildBottomNavigationBar(
                navigationShell: navigationShell,
                items: const [
                  BottomNavigationItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Home',
                  ),
                  BottomNavigationItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'Profile',
                  ),
                  BottomNavigationItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings_rounded,
                    label: 'Setting',
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
