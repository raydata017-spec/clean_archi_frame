import 'package:flutter/material.dart';

import '../colors.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color customBackground;
  final Color cardShadow;

  const AppColorsExtension({
    required this.customBackground,
    required this.cardShadow,
  });

  // Light Mode Color Mapping
  static const light = AppColorsExtension(
    customBackground: AppColors.white,
    cardShadow: AppColors.grey,
  );

  // Dark Mode Color Mapping
  static const dark = AppColorsExtension(
    customBackground: AppColors.black,
    cardShadow: Colors.transparent,
  );

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? customBackground,
    Color? cardShadow,
  }) {
    return AppColorsExtension(
      customBackground: customBackground ?? this.customBackground,
      cardShadow: cardShadow ?? this.cardShadow,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      customBackground: Color.lerp(customBackground, other.customBackground, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
    );
  }
}
