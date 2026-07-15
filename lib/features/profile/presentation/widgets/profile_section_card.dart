import 'package:flutter/material.dart';

import '../../../../app/config/dimensions.dart';
import '../../../../core/utils/extensions/context_extension.dart';

class ProfileSectionCard extends StatelessWidget {
  final List<Widget> children;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final Border? border;

  const ProfileSectionCard({
    super.key,
    required this.children,
    this.backgroundColor,
    this.boxShadow,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.all(
          Radius.circular(AppSizes.borderRadiusMd),
        ),
        border: border,
        boxShadow: boxShadow,
      ),
      child: Column(
        children: children,
      ),
    );
  }
}
