import 'package:flutter/material.dart';

import '../../../../app/config/navigation_config.dart';

extension AppBarExtension on BuildContext {
  // Returns a leading drawer menu icon button if drawer navigation is enabled, else null
  Widget? get drawerLeading {
    final showDrawer = NavigationConfig.mode == NavigationType.drawer ||
        NavigationConfig.mode == NavigationType.both;
    if (!showDrawer) return null;
    return IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () => NavigationConfig.scaffoldKey.currentState?.openDrawer(),
    );
  }
}
