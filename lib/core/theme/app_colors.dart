import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand
  static const Color primary = Color(0xFF3D52FF);
  static const Color primaryPressed = Color(0xFF2438D8);
  static const Color primaryLight = Color(0xFF6B7BFF);
  static const Color primarySoft = Color(0xFFEEF0FF);
  static const Color primaryOnDark = Color(0xFFFFFFFF);

  // Workspace canvas
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF6F5F4);
  static const Color surfaceSoft = Color(0xFFFAFAF9);
  static const Color surfaceCard = Color(0xFFFFFFFF);

  // Borders
  static const Color hairline = Color(0xFFE5E3DF);
  static const Color hairlineSoft = Color(0xFFEDE9E4);
  static const Color hairlineStrong = Color(0xFFC8C4BE);

  // Text
  static const Color ink = Color(0xFF1A1A1A);
  static const Color charcoal = Color(0xFF37352F);
  static const Color slate = Color(0xFF5D5B54);
  static const Color steel = Color(0xFF787671);
  static const Color stone = Color(0xFFA4A097);
  static const Color muted = Color(0xFFBBB8B1);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Pastel status and supporting surfaces
  static const Color tintPeach = Color(0xFFFFE8D4);
  static const Color tintRose = Color(0xFFFDE0EC);
  static const Color tintMint = Color(0xFFD9F3E1);
  static const Color tintLavender = Color(0xFFE6E0F5);
  static const Color tintSky = Color(0xFFDCECFA);
  static const Color tintYellow = Color(0xFFFEF7D6);

  // Semantic
  static const Color success = Color(0xFF1AAE39);
  static const Color warning = Color(0xFFDD5B00);
  static const Color error = Color(0xFFE03131);
  static const Color info = Color(0xFF0075DE);

  static const Color successSoft = tintMint;
  static const Color warningSoft = tintYellow;
  static const Color errorSoft = tintRose;
  static const Color infoSoft = tintSky;

  // Compatibility aliases for existing code during the redesign.
  static const Color background = surface;
  static const Color backgroundTop = surface;
  static const Color backgroundMiddle = surfaceSoft;
  static const Color backgroundBottom = canvas;

  static const Color accentBlue = primary;
  static const Color accentCyan = info;
  static const Color accentPurple = tintLavender;
  static const Color accentPink = tintRose;

  static const Color surfaceL1 = canvas;
  static const Color surfaceL2 = surfaceSoft;
  static const Color surfaceL3 = surface;

  static const Color glassStrong = canvas;
  static const Color glassMedium = surfaceCard;
  static const Color glassSoft = surfaceSoft;
  static const Color glassFill = surfaceCard;
  static const Color glassBorderStrong = hairlineStrong;
  static const Color glassBorderSoft = hairline;
  static const Color glassBorder = hairline;
  static const Color glassStroke = hairlineSoft;
  static const Color glassOverlay = surfaceSoft;
  static const Color glassInset = surface;

  static const Color textPrimary = ink;
  static const Color textSecondary = slate;
  static const Color textTertiary = steel;

  static const Color borderSubtle = hairline;
  static const Color borderMedium = hairlineStrong;
  static const Color divider = hairlineSoft;

  static const Color shadowBase = Color(0xFF0F0F0F);
  static const Color shadowPrimary = primary;
  static const Color scrim = Color(0x661A1A1A);
}
