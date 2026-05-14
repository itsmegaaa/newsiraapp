import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';

class SiraStatusBadge extends StatelessWidget {
  const SiraStatusBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final status = label.toUpperCase();
    Color softColor = AppColors.infoSoft;
    Color color = AppColors.info;

    switch (status) {
      case 'SELESAI':
        softColor = AppColors.successSoft;
        color = AppColors.success;
        break;
      case 'PROSES':
      case 'PROSES TANDATANGAN':
        softColor = AppColors.infoSoft;
        color = AppColors.info;
        break;
      case 'PENDING':
        softColor = AppColors.warningSoft;
        color = AppColors.warning;
        break;
      case 'BATAL':
      case 'BERMASALAH':
        softColor = AppColors.errorSoft;
        color = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: AppRadius.btnPill,
      ),
      child: Text(
        status.isEmpty ? '-' : status,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
