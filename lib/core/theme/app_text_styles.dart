import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract class AppTextStyles {
  static const TextStyle displayLarge = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.15,
    color: AppColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingL = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingM = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyL = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyM = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelM = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.4,
    color: AppColors.textTertiary,
  );

  static const TextStyle numeric = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
