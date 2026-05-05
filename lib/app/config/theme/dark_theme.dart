import 'package:flutter/material.dart';
import '../colors.dart';
import 'app_colors_extension.dart';

final ThemeData darkThemeData = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.black,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    error: AppColors.error,
  ),
  extensions: const [
    AppColorsExtension.dark,
  ],
);
