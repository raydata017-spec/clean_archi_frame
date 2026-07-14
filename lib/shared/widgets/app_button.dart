import 'package:flutter/material.dart';

import '../../app/config/dimensions.dart';

class AppButton extends StatelessWidget {
  final double? btnWidth;
  final double? btnHeight;
  final String btnTitle;
  final VoidCallback? btnFunction;
  final Widget? child;
  final Color? btnColor;
  final bool isOutline;
  final TextStyle? btnTextStyle;
  final bool isLoading;
  final bool isEnabled;

  const AppButton({
    super.key,
    this.btnWidth,
    this.btnHeight,
    this.child,
    this.btnColor,
    this.isOutline = false,
    required this.btnTitle,
    required this.btnFunction,
    this.btnTextStyle,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Check if the button is actually clickable
    final isClickable = isEnabled && !isLoading && btnFunction != null;

    // TextStyle definition
    final effectiveTextStyle = btnTextStyle ??
        TextStyle(
          color: isOutline
              ? (isClickable
                  ? (btnColor ?? colorScheme.primary)
                  : colorScheme.onSurface.withValues(alpha: 0.38))
              : (isClickable
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface.withValues(alpha: 0.38)),
          fontSize: AppSizes.fontSizeSm,
          fontWeight: FontWeight.w600,
        );

    // Loader widget
    Widget buildLoader() {
      final loaderColor = isOutline ? (btnColor ?? colorScheme.primary) : colorScheme.onPrimary;
      return SizedBox(
        width: AppSizes.iconSm,
        height: AppSizes.iconSm,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
        ),
      );
    }

    final buttonChild = isLoading
        ? buildLoader()
        : (child ??
            Text(
              btnTitle,
              style: effectiveTextStyle,
            ));

    return SizedBox(
      width: btnWidth ?? double.infinity,
      child: isOutline
          ? OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: Size(0, btnHeight ?? AppSizes.buttonHeightMd + 8.0),
                side: BorderSide(
                  color: isClickable
                      ? (btnColor ?? colorScheme.primary)
                      : colorScheme.onSurface.withValues(alpha: 0.12),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSizes.borderRadiusMd,
                  ),
                ),
              ),
              onPressed: isClickable ? btnFunction : null,
              child: buttonChild,
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(0, btnHeight ?? AppSizes.buttonHeightMd + 8.0),
                backgroundColor: isClickable
                    ? (btnColor ?? colorScheme.primary)
                    : colorScheme.onSurface.withValues(alpha: 0.12),
                disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSizes.borderRadiusMd,
                  ),
                ),
              ),
              onPressed: isClickable ? btnFunction : null,
              child: buttonChild,
            ),
    );
  }
}
