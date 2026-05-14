// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Enumerates the different semantic statuses used for data. Extend
/// this enum if additional statuses are introduced in the future.
enum SiraStatus { success, warning, error, info }

/// A pill‑shaped badge used to indicate status. The background and
/// text colours are determined by the [status] provided.
class SiraStatusBadge extends StatelessWidget {
  final String text;
  final SiraStatus status;
  final bool small;

  const SiraStatusBadge({
    super.key,
    required this.text,
    required this.status,
    this.small = false,
  });

  Color get _backgroundColor {
    switch (status) {
      case SiraStatus.success:
        return AppColors.success.withOpacity(0.1);
      case SiraStatus.warning:
        return AppColors.warning.withOpacity(0.1);
      case SiraStatus.error:
        return AppColors.error.withOpacity(0.1);
      case SiraStatus.info:
      default:
        return AppColors.primary.withOpacity(0.1);
    }
  }

  Color get _textColor {
    switch (status) {
      case SiraStatus.success:
        return AppColors.success;
      case SiraStatus.warning:
        return AppColors.warning;
      case SiraStatus.error:
        return AppColors.error;
      case SiraStatus.info:
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = small ? AppSpacing.sm : AppSpacing.md;
    final vertical = small ? AppSpacing.xs : AppSpacing.sm;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(color: _textColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}