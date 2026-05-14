import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';

enum SiraGlassTone { hero, panel, metric, subtle }

class SiraGlassCard extends StatelessWidget {
  const SiraGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.borderRadius,
    this.subtle = false,
    this.tone,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final bool subtle;
  final SiraGlassTone? tone;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolvedTone =
        tone ?? (subtle ? SiraGlassTone.subtle : SiraGlassTone.panel);
    final spec = _WorkspaceCardSpec.forTone(resolvedTone);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? spec.color,
        borderRadius: borderRadius ?? AppRadius.cardLg,
        border: Border.all(color: spec.borderColor, width: spec.borderWidth),
        boxShadow: spec.shadows,
      ),
      child: child,
    );
  }
}

class _WorkspaceCardSpec {
  const _WorkspaceCardSpec({
    required this.color,
    required this.borderColor,
    required this.borderWidth,
    required this.shadows,
  });

  final Color color;
  final Color borderColor;
  final double borderWidth;
  final List<BoxShadow> shadows;

  static _WorkspaceCardSpec forTone(SiraGlassTone tone) {
    switch (tone) {
      case SiraGlassTone.hero:
        return const _WorkspaceCardSpec(
          color: AppColors.surfaceCard,
          borderColor: AppColors.hairline,
          borderWidth: 1,
          shadows: AppShadows.subtle,
        );
      case SiraGlassTone.panel:
        return const _WorkspaceCardSpec(
          color: AppColors.surfaceCard,
          borderColor: AppColors.hairline,
          borderWidth: 1,
          shadows: AppShadows.none,
        );
      case SiraGlassTone.metric:
        return const _WorkspaceCardSpec(
          color: AppColors.surfaceSoft,
          borderColor: AppColors.hairlineSoft,
          borderWidth: 1,
          shadows: AppShadows.none,
        );
      case SiraGlassTone.subtle:
        return const _WorkspaceCardSpec(
          color: AppColors.surfaceCard,
          borderColor: AppColors.hairlineSoft,
          borderWidth: 1,
          shadows: AppShadows.none,
        );
    }
  }
}
