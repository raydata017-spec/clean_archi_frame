import 'package:flutter/material.dart';

enum NavigationType {
  bottomNav,
  drawer,
  both,
}

class NavigationConfig {
  // Configures the layout of navigation: bottomNav, drawer, or both
  static const NavigationType mode = NavigationType.drawer;

  // Global key to manage Scaffold state from nested screens
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Flag to check if the app is currently in the process of exiting
  static bool isExiting = false;
}
