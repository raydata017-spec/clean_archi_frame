import 'package:flutter/material.dart';
import '../colors.dart';
import 'app_colors_extension.dart';

final ThemeData lightThemeData = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.white,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    error: AppColors.error,
  ),
  extensions: const [
    AppColorsExtension.light,
  ],
);
