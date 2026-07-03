import 'package:flutter/material.dart';

import '../../app/config/dimensions.dart';
import '../../core/utils/extensions/context_extension.dart';

/// Flexible Alert Dialog
class AppAlertDialog extends StatelessWidget {
  const AppAlertDialog({
    super.key,
    required this.title,
    required this.content,
    this.contentAlign,
    // Confirm button
    this.onConfirm,
    this.confirmLabel = 'OK',
    this.confirmColor,
    // Cancel button (optional)
    this.onCancel,
    this.cancelLabel = 'Cancel',
    this.cancelColor,
  });

  final String title;
  final String content;
  final TextAlign? contentAlign;

  // --- Confirm button ---
  final VoidCallback? onConfirm;
  final String confirmLabel;
  final Color? confirmColor;

  // --- Cancel button (optional) ---
  final VoidCallback? onCancel;
  final String cancelLabel;
  final Color? cancelColor;

  @override
  Widget build(BuildContext context) {
    final hasButtons = onConfirm != null || onCancel != null;

    return Dialog(
      backgroundColor: context.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.paddingMarginMd,
          horizontal: AppSizes.paddingMarginLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: context.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: AppSizes.fontSizeLg,
                color: context.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwTexts),

            // Content
            Text(
              content,
              style: context.textTheme.bodyMedium!.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: .5),
              ),
              textAlign: contentAlign,
            ),

            // Buttons section
            if (hasButtons) ...[
              const SizedBox(height: AppSizes.spaceBtwItems),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel button
                  if (onCancel != null)
                    TextButton(
                      onPressed: onCancel,
                      style: TextButton.styleFrom(
                        foregroundColor:
                            cancelColor ?? context.colorScheme.onSurface.withValues(alpha: .6),
                      ),
                      child: Text(cancelLabel),
                    ),

                  // Confirm button
                  if (onConfirm != null)
                    TextButton(
                      onPressed: onConfirm,
                      style: TextButton.styleFrom(
                        foregroundColor: confirmColor ?? context.colorScheme.primary,
                      ),
                      child: Text(confirmLabel),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
