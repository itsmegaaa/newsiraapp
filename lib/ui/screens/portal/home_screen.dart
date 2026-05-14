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
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/globals.dart';
import '../../../data/repositories/laporan_repository.dart';
import '../../layout/sira_responsive_shell.dart';
import '../../navigation/sira_page_route.dart';
import '../../widgets/sira_glass_card.dart';
import '../../widgets/sira_primary_button.dart';
import '../../widgets/sira_secondary_button.dart';
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
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _DashboardHero(
              greeting: getSapaanWaktu(),
              userName: userProv.nama.isEmpty ? 'SIRA Projects' : userProv.nama,
              totalBerkas: laporanCtrl.totalBerkas.toString(),
              totalBulanIni: laporanCtrl.totalBulanIni.toString(),
              totalBermasalah: laporanCtrl.totalBermasalah.toString(),
            ),
            const SizedBox(height: AppSpacing.lg),
            StreamBuilder<DocumentSnapshot>(
              stream: context.read<LaporanRepository>().streamSyncStatus(),
              builder: (context, snapshot) {
                final syncText = _buildSyncText(snapshot.data);
                return SiraGlassCard(
                  tone: SiraGlassTone.panel,
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.15),
                              AppColors.accentCyan.withValues(alpha: 0.12),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.verified_outlined,
                          color: AppColors.primary,
                          size: 21,
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
                                  ?.copyWith(fontWeight: FontWeight.w700),
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
            const SizedBox(height: AppSpacing.lg),
            GridView.count(
              crossAxisCount: isDesktop ? 3 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: isDesktop ? AppSpacing.sm : AppSpacing.sm,
              mainAxisSpacing: isDesktop ? AppSpacing.sm : AppSpacing.sm,
              childAspectRatio: isDesktop ? 2.7 : 2.25,
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
            SiraGlassCard(
              subtle: true,
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Wrap(
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
                child: SiraGlassCard(
                  subtle: true,
                  padding: const EdgeInsets.all(AppSpacing.base),
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

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({
    required this.greeting,
    required this.userName,
    required this.totalBerkas,
    required this.totalBulanIni,
    required this.totalBermasalah,
  });

  final String greeting;
  final String userName;
  final String totalBerkas;
  final String totalBulanIni;
  final String totalBermasalah;

  @override
  Widget build(BuildContext context) {
    return SiraGlassCard(
      tone: SiraGlassTone.hero,
      borderRadius: AppRadius.cardXl,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            userName,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(
              'Pantau ritme kerja, progres berkas, dan aktivitas tim dari satu dashboard yang lebih bersih.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 560;
              final chips = [
                _HeroStatChip(
                  label: 'Total Berkas',
                  value: totalBerkas,
                  icon: Icons.folder_copy_outlined,
                ),
                _HeroStatChip(
                  label: 'Masuk Bulan Ini',
                  value: totalBulanIni,
                  icon: Icons.calendar_month_outlined,
                ),
                _HeroStatChip(
                  label: 'Butuh Atensi',
                  value: totalBermasalah,
                  icon: Icons.priority_high_rounded,
                ),
              ];

              if (isCompact) {
                return Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: chips
                      .map(
                        (chip) =>
                            SizedBox(width: constraints.maxWidth, child: chip),
                      )
                      .toList(),
                );
              }

              return Row(
                children: chips
                    .map(
                      (chip) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: chip,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeroStatChip extends StatelessWidget {
  const _HeroStatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: AppRadius.cardMd,
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
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
    final isCompactMobile = MediaQuery.of(context).size.width < 420;
    final isWideScreen = MediaQuery.of(context).size.width >= AppBreakpoints.mobile;

    return SiraGlassCard(
      tone: SiraGlassTone.metric,
      padding: EdgeInsets.symmetric(
        horizontal: isCompactMobile ? AppSpacing.sm : (isWideScreen ? 10 : AppSpacing.md),
        vertical: isCompactMobile ? 10 : (isWideScreen ? 8 : AppSpacing.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: isCompactMobile ? 30 : (isWideScreen ? 30 : 36),
            height: isCompactMobile ? 30 : (isWideScreen ? 30 : 36),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.22),
                  color.withValues(alpha: 0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(isCompactMobile ? 8 : (isWideScreen ? 9 : 10)),
              border: Border.all(color: color.withValues(alpha: 0.14)),
            ),
            child: Icon(icon, color: color, size: isCompactMobile ? 15 : (isWideScreen ? 15 : 18)),
          ),
          SizedBox(width: isCompactMobile ? AppSpacing.xs : AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: isCompactMobile ? 18 : (isWideScreen ? 18 : 22),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: isCompactMobile ? 1 : 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                    fontSize: isCompactMobile ? 11 : (isWideScreen ? 11 : null),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
