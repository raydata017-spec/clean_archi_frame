import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/config/dimensions.dart';
import '../../core/utils/extensions/context_extension.dart';

class AppEmptyWidget extends StatelessWidget {
  final String? imageUrl;
  final String? title;
  final String? subtitle;
  final Widget? action;

  const AppEmptyWidget({
    super.key,
    this.imageUrl,
    this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMarginLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image/Icon section
            if (imageUrl != null) ...[
              imageUrl!.toLowerCase().endsWith('.svg')
                  ? SvgPicture.asset(imageUrl!)
                  : Image.asset(imageUrl!),
              const SizedBox(height: AppSizes.spaceBtwItems),
            ],

            // Title section
            if (title != null && title!.isNotEmpty) ...[
              Text(
                title!,
                textAlign: TextAlign.center,
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: .5),
                ),
              ),
            ],

            // Subtitle spacing and section
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: AppSizes.paddingMarginSm),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: .3),
                ),
              ),
            ],

            // Action section spacing and button
            if (action != null) ...[
              const SizedBox(height: AppSizes.spaceBtwSections / 2),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
