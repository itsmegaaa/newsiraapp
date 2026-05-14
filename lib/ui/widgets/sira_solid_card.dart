import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';

class SiraSolidCard extends StatelessWidget {
  const SiraSolidCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.base),
    this.borderRadius,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceL1,
        borderRadius: borderRadius ?? AppRadius.cardMd,
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.subtle,
      ),
      child: child,
    );
  }
}
