import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.surfaceBase,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surfacePanel,
        primary: AppColors.traceCalm,
        secondary: AppColors.traceHot,
        error: AppColors.statusDanger,
        onSurface: AppColors.textPrimary,
      ),
    );
  }
}
