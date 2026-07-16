import 'package:flutter/material.dart';
import '../../../../app/config/dimensions.dart';
import '../../../../core/utils/extensions/context_extension.dart';

class ProfileActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const ProfileActionRow({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final finalIconColor = iconColor ?? context.colorScheme.onSurface.withValues(alpha: 0.8);
    final finalTextColor = textColor ?? context.colorScheme.onSurface;

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
              color: finalIconColor,
            ),
            const SizedBox(width: AppSizes.spaceBtwItems),
            Expanded(
              child: Text(
                title,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: finalTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: AppSizes.iconMd,
              color: context.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
