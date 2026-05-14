import 'package:flutter/material.dart';

/// Defines all colour tokens used throughout the application.
///
/// These values are inspired by the SIRA Projects design brief, where
/// light mode is the only supported colour scheme and the interface
/// adopts a frosted glass aesthetic. Colours are kept soft and
/// desaturated so that content remains the focus. Do not use
/// `Colors.white` or `Colors.black` directly—refer to these tokens
/// instead to ensure consistency.
class AppColors {
  AppColors._();

  /// Base page background. Should be used for the outermost Scaffold
  /// background and page backgrounds.
  static const Color background = Color(0xFFF5F5F7);

  /// Primary surface colour for cards and containers. This is a solid
  /// white with a subtle tint to match the background. Use for most
  /// SolidCard backgrounds.
  static const Color surfaceL1 = Color(0xFFFFFFFF);

  /// Secondary surface for slight contrast against surfaceL1. Use for
  /// nested surfaces or subtle segmentation.
  static const Color surfaceL2 = Color(0xFFF9F9FC);

  /// Tertiary surface for very subtle contrast. Useful when stacking
  /// cards or separating components.
  static const Color surfaceL3 = Color(0xFFF2F3F7);

  /// A semi‑transparent colour used behind frosted glass widgets. This
  /// creates the blurred glass effect when combined with BackdropFilter.
  static const Color glassBackground = Color(0x66FFFFFF);

  /// Border colours for delineating components. Use `borderSubtle` for
  /// light separators and `borderMedium` for stronger dividers.
  static const Color borderSubtle = Color(0xFFD4D4D8);
  static const Color borderMedium = Color(0xFFC0C0C8);

  /// The primary accent colour. All highlights, buttons and active
  /// indicators should use this hue. The value comes from the SIRA
  /// design brief (indigo). Variants are derived by adjusting opacity.
  static const Color primary = Color(0xFF3D52FF);
  static const Color primarySoft = Color(0xFFECEEFF);

  /// Semantic colours conveying status. These are used for status
  /// badges, toast icons and text. Only change these values if
  /// altering the entire colour palette.
  static const Color success = Color(0xFF2CA36F);
  static const Color warning = Color(0xFFFFB020);
  static const Color error = Color(0xFFEB5757);

  /// Text colours. The names imply the level of emphasis to apply.
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF4F4F52);
  static const Color textTertiary = Color(0xFF8C8C92);
}