import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../controllers/form_laporan_controller.dart';
import '../../../controllers/laporan_controller.dart';
import '../../../controllers/user_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/globals.dart';
import '../../../data/repositories/laporan_repository.dart';
import '../../layout/sira_responsive_shell.dart';
import '../../navigation/sira_page_route.dart';
import '../../widgets/sira_glass_card.dart';
import '../../widgets/sira_primary_button.dart';
import '../../widgets/sira_secondary_button.dart';
import '../../widgets/sira_solid_card.dart';
import '../dashboard/laporan_screen.dart';
import '../form/form_laporan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserProvider>();
    final laporanCtrl = context.watch<LaporanController>();
    final isDesktop =
        MediaQuery.of(context).size.width >= AppBreakpoints.mobile;

    return SiraResponsiveShell(
      title: 'Dashboard',
      activeMenu: SiraMenu.dashboard,
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => laporanCtrl.mulaiListen(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SiraGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getSapaanWaktu(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    userProv.nama.isEmpty ? 'SIRA Projects' : userProv.nama,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: AppSpacing.base),
                  Text(
                    'Pantau ritme kerja, progres berkas, dan aktivitas tim dari satu dashboard yang lebih bersih.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Wrap(
                    spacing: AppSpacing.base,
                    runSpacing: AppSpacing.base,
                    children: [
                      _HeroStat(
                        label: 'Total Berkas',
                        value: laporanCtrl.totalBerkas.toString(),
                      ),
                      _HeroStat(
                        label: 'Masuk Bulan Ini',
                        value: laporanCtrl.totalBulanIni.toString(),
                      ),
                      _HeroStat(
                        label: 'Butuh Atensi',
                        value: laporanCtrl.totalBermasalah.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            StreamBuilder<DocumentSnapshot>(
              stream: context.read<LaporanRepository>().streamSyncStatus(),
              builder: (context, snapshot) {
                final syncText = _buildSyncText(snapshot.data);
                return SiraSolidCard(
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.verified_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status Sinkronisasi',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              syncText,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            GridView.count(
              crossAxisCount: isDesktop ? 3 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.base,
              mainAxisSpacing: AppSpacing.base,
              childAspectRatio: isDesktop ? 1.35 : 1.15,
              children: [
                _MetricCard(
                  label: 'Proses',
                  value: laporanCtrl.totalProses.toString(),
                  color: AppColors.info,
                  icon: Icons.sync_alt_rounded,
                ),
                _MetricCard(
                  label: 'Pending',
                  value: laporanCtrl.totalPending.toString(),
                  color: AppColors.warning,
                  icon: Icons.schedule_outlined,
                ),
                if (isDesktop)
                  _MetricCard(
                    label: 'Bermasalah',
                    value: laporanCtrl.totalBermasalah.toString(),
                    color: AppColors.error,
                    icon: Icons.report_problem_outlined,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.base),
            Wrap(
              spacing: AppSpacing.base,
              runSpacing: AppSpacing.base,
              children: [
                SizedBox(
                  width: isDesktop ? 240 : double.infinity,
                  child: SiraPrimaryButton(
                    label: 'Input Laporan',
                    icon: Icons.add_rounded,
                    onPressed: () async {
                      await context.read<FormLaporanController>().initForm(
                        laporanExisting: null,
                        tahunAktif: laporanCtrl.tahunAktif,
                      );
                      if (!context.mounted) return;
                      Navigator.of(
                        context,
                      ).push(SiraPageRoute(child: const FormLaporanScreen()));
                    },
                    expanded: !isDesktop,
                  ),
                ),
                SizedBox(
                  width: isDesktop ? 240 : double.infinity,
                  child: SiraSecondaryButton(
                    label: 'Buka Arsip Tahun Aktif',
                    icon: Icons.folder_open_outlined,
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).push(SiraPageRoute(child: const LaporanScreen()));
                    },
                  ),
                ),
              ],
            ),
            if (userProv.isAdmin) ...[
              const SizedBox(height: AppSpacing.base),
              SizedBox(
                width: isDesktop ? 240 : double.infinity,
                child: SiraSecondaryButton(
                  label: 'Sync ke Google Sheet',
                  icon: Icons.sync_rounded,
                  onPressed: () =>
                      _showSyncDialog(context, userProv.email, laporanCtrl),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Arsip Tahunan',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.base),
            ...AppConstants.listTahunAktif.reversed.map(
              (tahun) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: SiraSolidCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calendar_month_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      'Data Tahun $tahun',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Buka daftar laporan untuk tahun ini',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                    onTap: () {
                      context.read<LaporanController>().ubahTahun(tahun);
                      Navigator.of(
                        context,
                      ).push(SiraPageRoute(child: const LaporanScreen()));
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildSyncText(DocumentSnapshot? snapshot) {
    if (snapshot == null || !snapshot.exists) {
      return 'Belum ada riwayat sinkronisasi.';
    }
    final data = snapshot.data() as Map<String, dynamic>?;
    if (data == null) return 'Belum ada riwayat sinkronisasi.';
    if (data['isSyncing'] == true) {
      return 'Sedang sinkronisasi ke Google Sheets.';
    }

    final last = data['lastSyncToSheet'] as Timestamp?;
    if (last == null) return 'Belum pernah sinkronisasi.';
    return 'Terakhir sync ${DateFormat('dd MMM yyyy, HH:mm').format(last.toDate())}.';
  }

  Future<void> _showSyncDialog(
    BuildContext context,
    String email,
    LaporanController ctrl,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sinkronisasi'),
        content: const Text('Kirim data terbaru ke Google Sheet sekarang?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Sync sekarang',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ctrl.triggerSyncManual(email);
    }
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SiraSolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
