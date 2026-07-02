import 'package:flutter/material.dart';

class BottomNavigationItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const BottomNavigationItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}
