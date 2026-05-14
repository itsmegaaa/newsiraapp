import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/repositories/laporan_repository.dart';
import '../../layout/sira_responsive_shell.dart';
import '../../widgets/sira_solid_card.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<LaporanRepository>();

    return SiraResponsiveShell(
      title: 'Riwayat Aktivitas',
      activeMenu: SiraMenu.log,
      child: StreamBuilder<QuerySnapshot>(
        stream: repo.streamLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2.4),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan saat memuat log.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
              ),
            );
          }

          final logs = snapshot.data?.docs ?? [];
          if (logs.isEmpty) {
            return const _EmptyLogState();
          }

          return ListView.separated(
            itemCount: logs.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final data = logs[index].data() as Map<String, dynamic>;
              return _LogCard(data: data);
            },
          );
        },
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  const _LogCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final aksi = data['aksi'] as String? ?? 'UNKNOWN';
    final detail = data['detail'] as String? ?? '-';
    final oleh = data['oleh'] as String? ?? 'Sistem';
    final waktu = data['waktu'] as Timestamp?;
    final semantic = _semanticForAction(aksi);

    return SiraSolidCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: semantic.softColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(semantic.icon, color: semantic.color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      aksi,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: semantic.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      waktu == null
                          ? '-'
                          : DateFormat(
                              'dd MMM yyyy, HH:mm',
                            ).format(waktu.toDate()),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(detail, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.base),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      oleh,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _ActionSemantic _semanticForAction(String aksi) {
    switch (aksi.toUpperCase()) {
      case 'TAMBAH':
        return const _ActionSemantic(
          AppColors.success,
          AppColors.successSoft,
          Icons.add_circle_outline_rounded,
        );
      case 'EDIT':
        return const _ActionSemantic(
          AppColors.info,
          AppColors.infoSoft,
          Icons.edit_outlined,
        );
      case 'HAPUS':
        return const _ActionSemantic(
          AppColors.error,
          AppColors.errorSoft,
          Icons.delete_outline_rounded,
        );
      case 'SYNC':
        return const _ActionSemantic(
          AppColors.primary,
          AppColors.primarySoft,
          Icons.sync_rounded,
        );
      default:
        return const _ActionSemantic(
          AppColors.warning,
          AppColors.warningSoft,
          Icons.info_outline_rounded,
        );
    }
  }
}

class _ActionSemantic {
  const _ActionSemantic(this.color, this.softColor, this.icon);

  final Color color;
  final Color softColor;
  final IconData icon;
}

class _EmptyLogState extends StatelessWidget {
  const _EmptyLogState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off_rounded,
            size: 72,
            color: AppColors.textTertiary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Belum ada riwayat aktivitas',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Log perubahan laporan akan muncul di sini.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
