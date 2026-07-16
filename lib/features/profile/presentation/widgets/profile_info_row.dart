import 'package:flutter/material.dart';
import '../../../../app/config/dimensions.dart';
import '../../../../core/utils/extensions/context_extension.dart';

class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMarginSm,
        vertical: AppSizes.paddingMarginSm,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppSizes.iconMd,
            color: context.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: AppSizes.spaceBtwItems),
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
