import 'package:flutter/material.dart';

import '../../app/config/dimensions.dart';
import '../../core/utils/extensions/context_extension.dart';

class AppAlertBottomSheet extends StatelessWidget {
  const AppAlertBottomSheet({
    super.key,
    required this.title,
    required this.content,
    this.contentAlign,
    this.onConfirm,
    this.confirmLabel = 'OK',
    this.confirmColor,
    this.onCancel,
    this.cancelLabel = 'Cancel',
    this.cancelColor,
    this.isConfirmElevated = false,
    this.isCancelElevated = false,
  });

  final String title;
  final String content;
  final TextAlign? contentAlign;

  // --- Confirm button ---
  final VoidCallback? onConfirm;
  final String confirmLabel;
  final Color? confirmColor;
  final bool isConfirmElevated;

  // --- Cancel button (optional) ---
  final VoidCallback? onCancel;
  final String cancelLabel;
  final Color? cancelColor;
  final bool isCancelElevated;

  @override
  Widget build(BuildContext context) {
    final hasButtons = onConfirm != null || onCancel != null;

    return SafeArea(
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
              const SizedBox(height: AppSizes.defaultSpace),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: AppSizes.spaceBtwButtons,
                children: [
                  // Cancel button
                  if (onCancel != null)
                    isCancelElevated
                        ? ElevatedButton(
                            onPressed: onCancel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cancelColor ??
                                  context.colorScheme.onSurface.withValues(alpha: .05),
                              foregroundColor: context.colorScheme.onSurface.withValues(alpha: .8),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                              ),
                            ),
                            child: Text(cancelLabel),
                          )
                        : TextButton(
                            onPressed: onCancel,
                            style: TextButton.styleFrom(
                              foregroundColor: cancelColor ??
                                  context.colorScheme.onSurface.withValues(alpha: .6),
                            ),
                            child: Text(cancelLabel),
                          ),

                  // Confirm button
                  if (onConfirm != null)
                    isConfirmElevated
                        ? ElevatedButton(
                            onPressed: onConfirm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: confirmColor ?? context.colorScheme.primary,
                              foregroundColor: context.colorScheme.onPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                              ),
                            ),
                            child: Text(confirmLabel),
                          )
                        : TextButton(
                            onPressed: onConfirm,
                            child: Text(
                              confirmLabel,
                              style: TextStyle(color: confirmColor ?? context.colorScheme.primary),
                            ),
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
