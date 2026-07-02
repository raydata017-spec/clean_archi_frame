import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/config/dimensions.dart';
import '../../../core/utils/extensions/context_extension.dart';
import 'bottom_navigation_item.dart';

class StandardBottomNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final List<BottomNavigationItem> items;

  const StandardBottomNavBar({
    super.key,
    required this.navigationShell,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = context.colorScheme.primary;
    final inactiveColor = context.colorScheme.onSurface.withValues(alpha: .6);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMarginLg,
        vertical: AppSizes.paddingMarginSm,
      ),
      decoration: BoxDecoration(
        color: context.colors.customBackground,
        boxShadow: [
          BoxShadow(
            color: context.colors.cardShadow.withValues(alpha: .08),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.borderRadiusLg),
          topRight: Radius.circular(AppSizes.borderRadiusLg),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = navigationShell.currentIndex == index;

            return GestureDetector(
              onTap: () {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spaceBtwItems,
                  vertical: AppSizes.paddingMarginSm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? activeColor.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusXXl),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                      color: isSelected ? activeColor : inactiveColor,
                      size: AppSizes.iconMd,
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: AppSizes.paddingMarginSm),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: activeColor,
                          fontSize: AppSizes.fontSizeSm,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
