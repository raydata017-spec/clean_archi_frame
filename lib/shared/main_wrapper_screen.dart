import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/config/navigation_config.dart';
import '../core/utils/extensions/bottom_navigation_extension.dart';
import 'widgets/bottom_nav/bottom_navigation_item.dart';
import 'widgets/custom_navigation_drawer.dart';

class MainWrapperScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapperScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final showBottomNav = NavigationConfig.mode == NavigationType.bottomNav ||
        NavigationConfig.mode == NavigationType.both;
    final showDrawer = NavigationConfig.mode == NavigationType.drawer ||
        NavigationConfig.mode == NavigationType.both;

    return Scaffold(
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
    );
  }
}

