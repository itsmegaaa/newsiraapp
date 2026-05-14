import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../controllers/form_laporan_controller.dart';
import '../../../controllers/user_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/laporan_model.dart';
import '../../layout/sira_responsive_shell.dart';
import '../../navigation/sira_page_route.dart';
import '../../widgets/sira_glass_card.dart';
import '../../widgets/sira_primary_button.dart';
import '../../widgets/sira_solid_card.dart';
import '../../widgets/sira_status_badge.dart';
import '../form/form_laporan_screen.dart';

class DetailLaporanScreen extends StatelessWidget {
  const DetailLaporanScreen({super.key, required this.item});

  final LaporanModel item;

  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserProvider>();

    return SiraResponsiveShell(
      title: 'Detail Berkas',
      activeMenu: SiraMenu.laporan,
      maxContentWidth: 720,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'project-card-${item.id}',
              child: Material(
                color: Colors.transparent,
                child: SiraGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.namaDebitur,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displaySmall,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  '${item.namaBank} - ${item.namaNotaris}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          SiraStatusBadge(label: item.statusPekerjaan),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Wrap(
                        spacing: AppSpacing.xl,
                        runSpacing: AppSpacing.base,
                        children: [
                          _HeaderMeta(
                            label: 'Tanggal Order',
                            value: _formatDate(item.tanggalOrder),
                          ),
                          _HeaderMeta(
                            label: 'Tanggal Pelaksanaan',
                            value: _formatDate(item.tanggalPelaksanaan),
                          ),
                          _HeaderMeta(
                            label: 'Batas SLA',
                            value: item.batasSla.isEmpty ? '-' : item.batasSla,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _DetailSection(
              title: 'Informasi Umum',
              items: [
                _DetailItem('Nama Notaris', item.namaNotaris),
                _DetailItem('KCU/KCP Bank', item.namaBank),
                _DetailItem('PIC Bank', item.picBank),
              ],
            ),
            const SizedBox(height: AppSpacing.base),
            _DetailSection(
              title: 'Detail Order',
              items: [
                _DetailItem('No. Surat Order', item.noSuratOrder),
                _DetailItem('Tanggal Order', _formatDate(item.tanggalOrder)),
                _DetailItem('Jenis', item.jenis),
                _DetailItem('Rincian Order', item.rincianOrder),
                _DetailItem('No. Covernote', item.noCovernote),
              ],
            ),
            const SizedBox(height: AppSpacing.base),
            _DetailSection(
              title: 'Finansial',
              items: [
                _DetailItem(
                  'Limit / Plafon',
                  _formatCurrency(item.limitPlafon),
                ),
                _DetailItem('Nilai HT', _formatCurrency(item.nilaiHT)),
                _DetailItem(
                  'Biaya Notaris',
                  _formatCurrency(item.biayaNotaris),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.base),
            _DetailSection(
              title: 'Pelaksanaan & SLA',
              items: [
                _DetailItem(
                  'Tanggal Pelaksanaan',
                  _formatDate(item.tanggalPelaksanaan),
                ),
                _DetailItem('Batas SLA', item.batasSla),
                _DetailItem('Umur Pekerjaan', item.umurPekerjaan),
              ],
            ),
            const SizedBox(height: AppSpacing.base),
            _DetailSection(
              title: 'Progres & Catatan',
              items: [
                _DetailItem('Status', item.statusPekerjaan),
                _DetailItem('Progres Terakhir', item.progresDetail),
                _DetailItem('Tanggal BAST', _formatDate(item.tanggalBast)),
                _DetailItem('Kekurangan Berkas', item.kekurangan),
                _DetailItem('Per Kasus', item.notes),
                _DetailItem('PIC Internal', item.picInternal),
              ],
            ),
            if (userProv.isAdmin) ...[
              const SizedBox(height: AppSpacing.xl),
              SiraPrimaryButton(
                label: 'Edit Berkas',
                icon: Icons.edit_outlined,
                onPressed: () async {
                  await context.read<FormLaporanController>().initForm(
                    laporanExisting: item,
                    tahunAktif: item.tahun,
                  );
                  if (!context.mounted) return;
                  Navigator.of(
                    context,
                  ).push(SiraPageRoute(child: const FormLaporanScreen()));
                },
                expanded: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatDate(String value) {
    if (value.isEmpty) return '-';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(value));
    } catch (_) {
      return value;
    }
  }

  static String _formatCurrency(String value) {
    if (value.isEmpty || value == '0') return 'Rp 0';
    final normalized = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized.isEmpty) return 'Rp 0';
    final formatter = NumberFormat.decimalPattern('id');
    return 'Rp ${formatter.format(int.parse(normalized))}';
  }
}

class _HeaderMeta extends StatelessWidget {
  const _HeaderMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.items});

  final String title;
  final List<_DetailItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SiraSolidCard(
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                _DetailRow(item: items[i]),
                if (i != items.length - 1) ...[
                  const SizedBox(height: AppSpacing.base),
                  const Divider(),
                  const SizedBox(height: AppSpacing.base),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.item});

  final _DetailItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          item.value.isEmpty ? '-' : item.value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _DetailItem {
  const _DetailItem(this.label, this.value);

  final String label;
  final String value;
}
