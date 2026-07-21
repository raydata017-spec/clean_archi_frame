import 'package:cupertino_back_gesture/cupertino_back_gesture.dart';
import 'package:flutter/material.dart';
import '../colors.dart';
import '../flavors/app_config.dart';
import 'app_colors_extension.dart';

ThemeData buildLightTheme({AppConfig? config}) {
  final primaryColor = config?.primaryColor ?? AppColors.primary;
  final secondaryColor = config?.secondaryColor ?? AppColors.secondary;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: AppColors.white,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: AppColors.error,
      surface: AppColors.white,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilderCustomBackGestureWidth(),
      },
    ),
    extensions: const [
      AppColorsExtension.light,
    ],
  );
}

final ThemeData lightThemeData = buildLightTheme();

