// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Provides reusable shadow presets for surfaces. These presets avoid
/// relying on the Material elevation system and instead define
/// shadows explicitly as recommended by the design guidelines.
class AppShadows {
  AppShadows._();

  /// A gentle shadow used on cards and panels. Keep this subtle so
  /// surfaces appear to float just above the background without
  /// distracting attention from the content.
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Colors.black12,
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  /// A medium shadow for slightly raised elements such as dialogs and
  /// hero cards. Adds depth without overpowering the layout.
  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Colors.black26,
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];

  /// A deeper shadow reserved for overlays and modals. Use sparingly.
  static const List<BoxShadow> deep = [
    BoxShadow(
      color: Colors.black38,
      offset: Offset(0, 4),
      blurRadius: 10,
      spreadRadius: 0,
    ),
  ];

  /// A glow effect used for primary elements like the primary button.
  /// Combines the primary colour with a blur to create a soft halo.
  static List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.4),
      offset: const Offset(0, 0),
      blurRadius: 10,
      spreadRadius: 0,
    ),
  ];
}