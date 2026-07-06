import 'package:flutter/material.dart';

class NavigatorKeys {
  NavigatorKeys._();

  static final root = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final shellHome = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
  static final shellProfile = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');
  static final shellSettings = GlobalKey<NavigatorState>(debugLabel: 'shellSettings');

  static GlobalKey<NavigatorState>? getActiveNavigator(int index) {
    switch (index) {
      case 0:
        return shellHome;
      case 1:
        return shellProfile;
      case 2:
        return shellSettings;
      default:
        return null;
    }
  }
}
