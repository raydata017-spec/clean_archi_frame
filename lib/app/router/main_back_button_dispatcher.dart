import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/navigation_config.dart';
import 'navigator_keys.dart';

class MainBackButtonDispatcher extends RootBackButtonDispatcher {
  final GoRouter goRouter;

  MainBackButtonDispatcher(this.goRouter);

  @override
  Future<bool> didPopRoute() async {
    if (NavigationConfig.isExiting) {
      return false; // let the system exit directly without calling pop scopes
    }

    // 1. Let GoRouter handle its routing stack pops (dialogs, sub-routes, etc.)
    if (await goRouter.routerDelegate.popRoute()) {
      return true;
    }

    // 2. If GoRouter cannot pop (meaning we are at the root of a branch), manually call maybePop on root navigator
    final rootContext = NavigatorKeys.root.currentContext;
    if (rootContext != null && rootContext.mounted) {
      if (await Navigator.maybePop(rootContext)) {
        return true;
      }
    }

    return false;
  }
}
