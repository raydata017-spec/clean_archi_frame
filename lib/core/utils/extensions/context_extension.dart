import 'package:flutter/material.dart';
import '../../../app/config/dimensions.dart';
import '../../../app/config/theme/app_colors_extension.dart';

extension ThemeContextExtension on BuildContext {
  // Material 3 Default Colors
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // Typography
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Custom Design Token Colors
  AppColorsExtension get colors => Theme.of(this).extension<AppColorsExtension>()!;

  // Common Input Decoration
  InputDecoration inputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: colorScheme.onSurface.withValues(alpha: .5),
        fontSize: AppSizes.fontSizeSm,
        fontWeight: FontWeight.normal,
      ),
      suffixIcon: suffixIcon,
      fillColor: colorScheme.surface.withValues(alpha: .9),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceBtwItems,
        vertical: AppSizes.cardRadiusMd,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        borderSide: BorderSide(
          color: colorScheme.onSurface.withValues(alpha: .2),
          width: AppSizes.dividerThickness,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        borderSide: BorderSide(
          color: colorScheme.onSurface.withValues(alpha: .2),
          width: AppSizes.dividerThickness,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        borderSide: BorderSide(
          color: colorScheme.error,
          width: AppSizes.dividerThickness,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        borderSide: BorderSide(
          color: colorScheme.error,
          width: 1.5,
        ),
      ),
    );
  }
}
