import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/custom_bottom_nav_bar.dart';

class MainWrapperScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapperScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,

      // Custom Bottom Navigation Bar
      bottomNavigationBar: CustomBottomNavBar(navigationShell: navigationShell),
    );
  }
}
