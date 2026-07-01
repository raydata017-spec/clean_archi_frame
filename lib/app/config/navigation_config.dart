import 'package:flutter/material.dart';

enum NavigationType {
  bottomNav,
  drawer,
  both,
}

class NavigationConfig {
  // Configures the layout of navigation: bottomNav, drawer, or both
  static const NavigationType mode = NavigationType.both;

  // Global key to manage Scaffold state from nested screens
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
}
