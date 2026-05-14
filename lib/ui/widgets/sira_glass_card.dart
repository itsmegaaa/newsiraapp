// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_shadows.dart';

/// A reusable glass card that applies a blur and semi‑transparent
/// background. Intended for top‑level floating elements such as
/// AppBar backgrounds, hero cards and bottom sheets. Avoid nesting
/// multiple [SiraGlassCard]s on one screen as this increases
/// rendering cost.
class SiraGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? radius;

  const SiraGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = Radius.circular(radius ?? AppRadius.cardL);
    return ClipRRect(
      borderRadius: BorderRadius.all(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
        child: Container(
          margin: margin ?? EdgeInsets.zero,
          padding: padding ?? const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: AppColors.glassBackground,
            borderRadius: BorderRadius.all(borderRadius),
            border: Border.all(color: AppColors.borderSubtle.withOpacity(0.5)),
            boxShadow: AppShadows.medium,
          ),
          child: child,
        ),
      ),
    );
  }
}