import 'package:flutter/material.dart';

import '../../../../app/config/dimensions.dart';
import '../../../../core/utils/extensions/context_extension.dart';

class SettingListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? iconColor;
  final Color? textColor;

  const SettingListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.trailing,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMarginSm,
          vertical: AppSizes.paddingMarginSm,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: AppSizes.iconMd,
              color: iconColor ?? context.colorScheme.onSurface.withValues(alpha: .7),
            ),
            const SizedBox(width: AppSizes.spaceBtwItems),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: textColor?.withValues(alpha: .7) ??
                          context.colorScheme.onSurface.withValues(alpha: .5),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
