import 'package:flutter/material.dart';

import '../../../app/config/theme/app_colors_extension.dart';

extension ThemeContextExtension on BuildContext {
  // Material 3 Default Colors
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // Typography
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Custom Design Token Colors
  AppColorsExtension get colors => Theme.of(this).extension<AppColorsExtension>()!;
}
