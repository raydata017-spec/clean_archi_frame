import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/config/dimensions.dart';
import '../../core/utils/extensions/context_extension.dart';

class CustomNavigationDrawer extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CustomNavigationDrawer({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: context.colorScheme.surface,
      child: Column(
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              color: context.colorScheme.primary.withValues(alpha: 0.05),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: AppSizes.profilePicLg,
                    backgroundColor: context.colorScheme.primary,
                    child: Icon(
                      Icons.person_rounded,
                      color: context.colorScheme.onPrimary,
                      size: AppSizes.iconLg,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingMarginSm),
                  Text(
                    'Console Admin',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Drawer Items
          _buildDrawerItem(
            context: context,
            icon: Icons.home_rounded,
            label: 'Home',
            index: 0,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.person_rounded,
            label: 'Profile',
            index: 1,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.settings_rounded,
            label: 'Setting',
            index: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = navigationShell.currentIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? context.colorScheme.primary
            : context.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? context.colorScheme.primary : context.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: context.colorScheme.primary.withValues(alpha: 0.05),
      onTap: () {
        // Close drawer first
        Navigator.pop(context);
        // Switch branch
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
    );
  }
}
