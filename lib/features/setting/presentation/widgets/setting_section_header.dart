import 'package:flutter/material.dart';

import '../../../../app/config/dimensions.dart';
import '../../../../core/utils/extensions/context_extension.dart';

class SettingSectionHeader extends StatelessWidget {
  final String title;
  const SettingSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSizes.paddingMarginXs,
        bottom: AppSizes.paddingMarginXs,
      ),
      child: Text(
        title.toUpperCase(),
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
