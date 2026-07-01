import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/config/navigation_config.dart';
import 'widgets/custom_bottom_nav_bar.dart';
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
      bottomNavigationBar: showBottomNav ? CustomBottomNavBar(navigationShell: navigationShell) : null,
    );
  }
}
