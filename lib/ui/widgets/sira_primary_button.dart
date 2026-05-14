import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';

class SiraPrimaryButton extends StatelessWidget {
  const SiraPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.expanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final content = TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        foregroundColor: AppColors.textInverse,
      ),
      child: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: AppColors.textInverse,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: AppColors.textInverse),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textInverse,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );

    final button = Container(
      width: expanded ? double.infinity : null,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.button),
        boxShadow: AppShadows.primaryGlow,
      ),
      child: content,
    );

    return button;
  }
}
