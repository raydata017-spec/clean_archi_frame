import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../app/config/localization/generated/translations.g.dart';
import '../app/config/navigation_config.dart';
import '../app/router/navigator_keys.dart';
import '../core/utils/extensions/bottom_navigation_extension.dart';
import '../core/utils/extensions/context_extension.dart';
import '../core/utils/extensions/dialog_extension.dart';
import 'widgets/app_alert_dialog.dart';
import 'widgets/bottom_nav/bottom_navigation_item.dart';
import 'widgets/custom_navigation_drawer.dart';

class MainWrapperScreen extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapperScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  State<MainWrapperScreen> createState() => _MainWrapperScreenState();
}

class _MainWrapperScreenState extends State<MainWrapperScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Reset when screen initialized
    NavigationConfig.isExiting = false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      NavigationConfig.isExiting = false;
    }
  }

  void _showExitDialog(BuildContext context) {
    context.showAppDialog(
      builder: (context) => AppAlertDialog(
        title: t.common.exitAppTitle,
        content: t.common.exitAppConfirm,
        cancelLabel: t.common.cancel,
        confirmLabel: t.common.exit,
        confirmColor: context.colorScheme.error,
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
    final showBottomNav = NavigationConfig.mode == NavigationType.bottomNav ||
        NavigationConfig.mode == NavigationType.both;
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

        // 2. Check if the active branch navigator can pop (nested navigation or dialogs inside branch)
        final activeNavigatorKey =
            NavigatorKeys.getActiveNavigator(widget.navigationShell.currentIndex);
        final canPop = activeNavigatorKey?.currentState?.canPop() ?? false;

        if (canPop) {
          activeNavigatorKey!.currentState!.pop();
          return;
        }

        // 3. Handle the back key logic for navigation mode.
        final isDrawerOnlyMode = NavigationConfig.mode == NavigationType.drawer;

        if (isDrawerOnlyMode) {
          _showExitDialog(context);
        } else {
          final currentIndex = widget.navigationShell.currentIndex;
          if (currentIndex == 0) {
            _showExitDialog(context);
          } else {
            widget.navigationShell.goBranch(0);
          }
        }
      },
      child: Scaffold(
        key: NavigationConfig.scaffoldKey,
        body: widget.navigationShell,
        drawer: showDrawer ? CustomNavigationDrawer(navigationShell: widget.navigationShell) : null,
        bottomNavigationBar: showBottomNav
            ? context.buildBottomNavigationBar(
                navigationShell: widget.navigationShell,
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
