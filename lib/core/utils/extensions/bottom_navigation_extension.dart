import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/bottom_nav/bottom_navigation_item.dart';
import '../../../shared/widgets/bottom_nav/standard_bottom_nav_bar.dart';

extension BottomNavigationExtension on BuildContext {
  /// Builds a swappable bottom navigation bar for the shell route.
  /// If a new design is required, this extension method can be updated or configured
  /// to return a different bottom navigation design.
  Widget buildBottomNavigationBar({
    required StatefulNavigationShell navigationShell,
    required List<BottomNavigationItem> items,
  }) {
    return StandardBottomNavBar(
      navigationShell: navigationShell,
      items: items,
    );
  }
}
