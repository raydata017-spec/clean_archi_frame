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
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMarginMd,
                vertical: AppSizes.paddingMarginMd,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: AppSizes.profilePicLg,
                    backgroundColor: context.colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.person_rounded,
                      color: context.colorScheme.primary,
                      size: AppSizes.iconMd,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceBtwItems),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Console Admin',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colorScheme.onSurface,
                            fontSize: AppSizes.fontSizeMd,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSizes.paddingMarginXs),
                        Text(
                          'admin@company.com',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: AppSizes.fontSizeXs,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Divider below header
          Divider(
            height: AppSizes.dividerHeight,
            thickness: AppSizes.dividerThickness,
            color: context.colorScheme.onSurface.withValues(alpha: 0.08),
          ),
          
          const SizedBox(height: AppSizes.spaceBtwItems),
          
          // Navigation Items (Expanded to push footer to bottom)
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
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
          ),
          
          // Footer Section
          Divider(
            height: AppSizes.dividerHeight,
            thickness: AppSizes.dividerThickness,
            color: context.colorScheme.onSurface.withValues(alpha: 0.08),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMarginMd,
              vertical: AppSizes.paddingMarginMd,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'v1.0.0',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: AppSizes.fontSizeXs,
                  ),
                ),
                Text(
                  'Clean Archi Frame',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: AppSizes.fontSizeXs,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
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
    
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMarginSm,
        vertical: AppSizes.paddingMarginXs,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Close drawer first
            context.pop();
            // Switch branch
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? context.colorScheme.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMarginMd,
              vertical: AppSizes.paddingMarginSm,
            ),
            child: Row(
              children: [
                // Minimalist indicator line
                Container(
                  width: AppSizes.dividerThickness * 3,
                  height: AppSizes.iconMd,
                  decoration: BoxDecoration(
                    color: isSelected ? context.colorScheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingMarginSm),
                Icon(
                  icon,
                  color: isSelected
                      ? context.colorScheme.primary
                      : context.colorScheme.onSurface.withValues(alpha: 0.6),
                  size: AppSizes.iconMd,
                ),
                const SizedBox(width: AppSizes.spaceBtwItems),
                Expanded(
                  child: Text(
                    label,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? context.colorScheme.primary
                          : context.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: AppSizes.fontSizeSm,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
