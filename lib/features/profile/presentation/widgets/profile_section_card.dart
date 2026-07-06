import 'package:flutter/material.dart';
import '../../../../app/config/dimensions.dart';

class ProfileSectionCard extends StatelessWidget {
  final List<Widget> children;

  const ProfileSectionCard({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.all(
          Radius.circular(AppSizes.borderRadiusMd),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}
