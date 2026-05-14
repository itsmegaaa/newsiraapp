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
import '../../../data/models/laporan_model.dart';
import '../../layout/sira_responsive_shell.dart';
import '../../navigation/sira_page_route.dart';
import '../../widgets/sira_secondary_button.dart';
import '../../widgets/sira_solid_card.dart';
import '../../widgets/sira_status_badge.dart';
import '../../widgets/sira_toast.dart';
import '../form/form_laporan_screen.dart';
import '../portal/detail_laporan_screen.dart';
import 'log_screen.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final laporanCtrl = context.watch<LaporanController>();
    final userProv = context.watch<UserProvider>();
    final isDesktop =
        MediaQuery.of(context).size.width >= AppBreakpoints.mobile;

    return SiraResponsiveShell(
      title: 'Laporan ${laporanCtrl.tahunAktif}',
      activeMenu: SiraMenu.laporan,
      floatingActionButton: userProv.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _openAddForm(context, laporanCtrl),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textInverse,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah'),
            )
          : null,
      actions: [
        if (userProv.isAdmin)
          IconButton(
            tooltip: 'Log aktivitas',
            onPressed: () {
              Navigator.of(
                context,
              ).push(SiraPageRoute(child: const LogScreen()));
            },
            icon: const Icon(Icons.history_outlined),
          ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SiraSolidCard(
            color: AppColors.surfaceL2,
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: laporanCtrl.cariLaporan,
                  decoration: InputDecoration(
                    hintText: 'Cari debitur, bank, atau covernote...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() => _searchCtrl.clear());
                              laporanCtrl.cariLaporan('');
                            },
                            icon: const Icon(Icons.close_rounded),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: AppSpacing.base),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final status in <String>[
                        'SEMUA',
                        ...AppConstants.listStatusPekerjaan,
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: _FilterChipButton(
                            label: status,
                            selected: laporanCtrl.statusFilter == status,
                            onTap: () {
                              setState(() {
                                laporanCtrl.ubahFilterStatus(status);
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Row(
            children: [
              Text(
                '${laporanCtrl.dataLaporan.length} berkas',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (userProv.isAdmin && isDesktop)
                SiraSecondaryButton(
                  label: 'Sync Sheet',
                  icon: Icons.sync_rounded,
                  onPressed: () =>
                      _confirmSync(context, laporanCtrl, userProv.email),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => laporanCtrl.mulaiListen(),
              child: laporanCtrl.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : laporanCtrl.dataLaporan.isEmpty
                  ? const _EmptyLaporanState()
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: laporanCtrl.dataLaporan.length,
                      itemBuilder: (context, index) {
                        final item = laporanCtrl.dataLaporan[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _LaporanListItem(
                            item: item,
                            isAdmin: userProv.isAdmin,
                            onTap: () {
                              Navigator.of(context).push(
                                SiraPageRoute(
                                  child: DetailLaporanScreen(item: item),
                                ),
                              );
                            },
                            onDelete: () =>
                                _deleteItem(context, item, userProv.email),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddForm(
    BuildContext context,
    LaporanController laporanCtrl,
  ) async {
    await context.read<FormLaporanController>().initForm(
      laporanExisting: null,
      tahunAktif: laporanCtrl.tahunAktif,
    );
    if (!context.mounted) return;
    Navigator.of(context).push(SiraPageRoute(child: const FormLaporanScreen()));
  }

  Future<void> _confirmSync(
    BuildContext context,
    LaporanController ctrl,
    String email,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sinkronisasi'),
        content: Text(
          'Tarik pembaruan data tahun ${ctrl.tahunAktif} ke Google Sheet sekarang?',
        ),
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
      if (!context.mounted) return;
      SiraToast.show(
        context,
        type: SiraToastType.success,
        message: 'Permintaan sinkronisasi sudah dikirim.',
      );
    }
  }

  Future<void> _deleteItem(
    BuildContext context,
    LaporanModel item,
    String userEmail,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data'),
        content: Text(
          'Apakah Anda yakin ingin menghapus data debitur ${item.namaDebitur}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<LaporanController>().hapusData(
        item.id,
        item.namaDebitur,
        userEmail,
      );
      if (!context.mounted) return;
      SiraToast.show(
        context,
        type: SiraToastType.success,
        message: '${item.namaDebitur} berhasil dihapus.',
      );
    } catch (_) {
      if (!context.mounted) return;
      SiraToast.show(
        context,
        type: SiraToastType.error,
        message: 'Gagal menghapus data.',
      );
    }
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.surfaceL1,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderSubtle,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _LaporanListItem extends StatefulWidget {
  const _LaporanListItem({
    required this.item,
    required this.isAdmin,
    required this.onTap,
    required this.onDelete,
  });

  final LaporanModel item;
  final bool isAdmin;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  State<_LaporanListItem> createState() => _LaporanListItemState();
}

class _LaporanListItemState extends State<_LaporanListItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Hero(
        tag: 'project-card-${item.id}',
        child: Material(
          color: Colors.transparent,
          child: SiraSolidCard(
            color: _hovered ? AppColors.surfaceL2 : AppColors.surfaceL1,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: EdgeInsets.zero,
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
                        Icons.folder_open_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.namaDebitur,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '${item.namaBank} - ${item.namaNotaris}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.md,
                            runSpacing: AppSpacing.xs,
                            children: [
                              _MetaText(
                                icon: Icons.calendar_month_outlined,
                                text: _formatTanggal(item.tanggalPelaksanaan),
                              ),
                              _MetaText(
                                icon: Icons.timer_outlined,
                                text: _buildSlaText(item),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SiraStatusBadge(label: item.statusPekerjaan),
                        if (widget.isAdmin) ...[
                          const SizedBox(height: AppSpacing.sm),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'delete') widget.onDelete();
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Hapus data'),
                              ),
                            ],
                            child: const Icon(
                              Icons.more_horiz_rounded,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTanggal(String isoDate) {
    if (isoDate.isEmpty) return 'Belum pelaksanaan';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(isoDate));
    } catch (_) {
      return isoDate;
    }
  }

  String _buildSlaText(LaporanModel item) {
    if (item.batasSla.isEmpty) return 'SLA belum ada';
    try {
      final deadline = DateTime.parse(item.batasSla);
      final sisa = deadline.difference(DateTime.now()).inDays;
      if (item.statusPekerjaan == 'SELESAI' ||
          item.statusPekerjaan == 'BATAL') {
        return 'Status final';
      }
      if (sisa < 0) return 'Overdue ${sisa.abs()} hari';
      return 'Sisa $sisa hari';
    } catch (_) {
      return 'SLA ${item.batasSla}';
    }
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: AppSpacing.xs),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _EmptyLaporanState extends StatelessWidget {
  const _EmptyLaporanState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 320,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_off_outlined,
                  size: 72,
                  color: AppColors.textTertiary.withValues(alpha: 0.7),
                ),
                const SizedBox(height: AppSpacing.base),
                Text(
                  'Belum ada data',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Coba ubah filter atau tambahkan laporan baru.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
