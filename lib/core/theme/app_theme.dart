import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';

ColorScheme get _colorScheme => const ColorScheme(
  brightness: Brightness.light,
  primary: AppColors.primary,
  onPrimary: AppColors.primaryOnDark,
  primaryContainer: AppColors.primarySoft,
  onPrimaryContainer: AppColors.primary,
  secondary: AppColors.primaryLight,
  onSecondary: AppColors.primaryOnDark,
  secondaryContainer: AppColors.primarySoft,
  onSecondaryContainer: AppColors.primary,
  error: AppColors.error,
  onError: AppColors.textInverse,
  errorContainer: AppColors.errorSoft,
  onErrorContainer: AppColors.error,
  surface: AppColors.surfaceL1,
  onSurface: AppColors.textPrimary,
  surfaceContainerHighest: AppColors.surfaceL3,
  outline: AppColors.borderSubtle,
  outlineVariant: AppColors.borderMedium,
  scrim: AppColors.scrim,
  shadow: AppColors.shadowBase,
);

ThemeData get siraLightTheme {
  final baseTextTheme = TextTheme(
    displayLarge: AppTextStyles.displayLarge,
    displaySmall: AppTextStyles.displaySmall,
    headlineLarge: AppTextStyles.headingL,
    headlineMedium: AppTextStyles.headingM,
    bodyLarge: AppTextStyles.bodyL,
    bodyMedium: AppTextStyles.bodyM,
    labelMedium: AppTextStyles.labelM,
    bodySmall: AppTextStyles.caption,
  );

  final themedText = GoogleFonts.interTextTheme(baseTextTheme).copyWith(
    displayLarge: GoogleFonts.inter(textStyle: AppTextStyles.displayLarge),
    displaySmall: GoogleFonts.inter(textStyle: AppTextStyles.displaySmall),
    headlineLarge: GoogleFonts.inter(textStyle: AppTextStyles.headingL),
    headlineMedium: GoogleFonts.inter(textStyle: AppTextStyles.headingM),
    bodyLarge: GoogleFonts.inter(textStyle: AppTextStyles.bodyL),
    bodyMedium: GoogleFonts.inter(textStyle: AppTextStyles.bodyM),
    labelMedium: GoogleFonts.inter(textStyle: AppTextStyles.labelM),
    bodySmall: GoogleFonts.inter(textStyle: AppTextStyles.caption),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: _colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: themedText,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: themedText.headlineMedium,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.surfaceL1,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardMd),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceL3,
      hintStyle: themedText.bodyMedium?.copyWith(color: AppColors.textTertiary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: AppRadius.inputSm,
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.inputSm,
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.inputSm,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.inputSm,
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.inputSm,
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      floatingLabelStyle: GoogleFonts.inter(
        color: AppColors.primary,
        fontWeight: FontWeight.w500,
      ),
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.primary,
      selectionColor: AppColors.primarySoft,
      selectionHandleColor: AppColors.primary,
    ),
  );
}
