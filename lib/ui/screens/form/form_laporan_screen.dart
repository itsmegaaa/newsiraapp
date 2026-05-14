import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../controllers/form_laporan_controller.dart';
import '../../../controllers/user_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/globals.dart';
import '../../../data/repositories/laporan_repository.dart';
import '../../layout/sira_responsive_shell.dart';
import '../../widgets/sira_primary_button.dart';
import '../../widgets/sira_solid_card.dart';
import '../../widgets/sira_toast.dart';

class FormLaporanScreen extends StatefulWidget {
  const FormLaporanScreen({super.key});

  @override
  State<FormLaporanScreen> createState() => _FormLaporanScreenState();
}

class _FormLaporanScreenState extends State<FormLaporanScreen> {
  final _formKey = GlobalKey<FormState>();
  List<String> _listNotaris = [];
  String _saveError = '';

  @override
  void initState() {
    super.initState();
    _muatMasterNotaris();
  }

  Future<void> _muatMasterNotaris() async {
    final repo = context.read<LaporanRepository>();
    final data = await repo.getMasterNotaris();
    if (!mounted) return;
    setState(() {
      _listNotaris = data;
    });
  }

  Future<void> _pilihTanggal(
    BuildContext context,
    DateTime? initialDate,
    Function(DateTime) onSelected,
  ) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(data: Theme.of(context), child: child!);
      },
    );

    if (pickedDate != null) {
      onSelected(pickedDate);
    }
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _saveError = '';
    });

    final userProv = context.read<UserProvider>();
    final ctrl = context.read<FormLaporanController>();
    final sukses = await ctrl.simpanData(userProv.email);

    if (!mounted) return;
    if (sukses) {
      SiraToast.show(
        context,
        type: SiraToastType.success,
        message: 'Data berhasil disimpan.',
      );
      Navigator.of(context).pop();
    } else {
      setState(() {
        _saveError = 'Gagal menyimpan data. Periksa koneksi lalu coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<FormLaporanController>();
    final isDesktop =
        MediaQuery.of(context).size.width >= AppBreakpoints.mobile;

    return SiraResponsiveShell(
      title: ctrl.isEditMode ? 'Edit Laporan' : 'Tambah Laporan',
      activeMenu: SiraMenu.laporan,
      maxContentWidth: 720,
      actions: [
        TextButton(
          onPressed: ctrl.isLoading ? null : _simpan,
          child: Text(
            'Simpan',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel(
                title: 'Informasi Umum',
                caption:
                    'Data identitas utama untuk berkas yang sedang dikelola.',
              ),
              SiraSolidCard(
                child: Column(
                  children: [
                    _LabeledField(
                      label: 'Nama Debitur (Wajib)',
                      child: TextFormField(
                        controller: ctrl.namaDebiturCtrl,
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Nama debitur wajib diisi.'
                            : null,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan nama debitur',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    _LabeledField(
                      label: 'Nama Notaris',
                      child: Autocomplete<String>(
                        optionsBuilder: (value) {
                          if (value.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return _listNotaris.where(
                            (option) => option.toLowerCase().contains(
                              value.text.toLowerCase(),
                            ),
                          );
                        },
                        onSelected: ctrl.setNamaNotaris,
                        fieldViewBuilder:
                            (
                              context,
                              textEditingController,
                              focusNode,
                              onFieldSubmitted,
                            ) {
                              if (ctrl.namaNotarisCtrl.text.isNotEmpty &&
                                  textEditingController.text.isEmpty) {
                                textEditingController.text =
                                    ctrl.namaNotarisCtrl.text;
                              }
                              return TextFormField(
                                controller: textEditingController,
                                focusNode: focusNode,
                                decoration: const InputDecoration(
                                  hintText: 'Pilih atau ketik nama notaris',
                                ),
                                onChanged: (val) =>
                                    ctrl.namaNotarisCtrl.text = val,
                              );
                            },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(16),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: isDesktop ? 520 : 320,
                                  maxHeight: 220,
                                ),
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final option = options.elementAt(index);
                                    return ListTile(
                                      title: Text(option),
                                      onTap: () => onSelected(option),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    _LabeledField(
                      label: 'KCU/KCP (Bank)',
                      child: Autocomplete<Map<String, dynamic>>(
                        optionsBuilder: (value) {
                          if (value.text.isEmpty) {
                            return const Iterable<Map<String, dynamic>>.empty();
                          }
                          return ctrl.listMasterBank.where((option) {
                            final namaBank = option['namaBank']
                                .toString()
                                .toLowerCase();
                            return namaBank.contains(value.text.toLowerCase());
                          });
                        },
                        displayStringForOption: (option) =>
                            option['namaBank'] as String,
                        onSelected: (selection) => ctrl.setNamaBankDanPic(
                          selection['namaBank'] as String,
                        ),
                        fieldViewBuilder:
                            (
                              context,
                              textEditingController,
                              focusNode,
                              onFieldSubmitted,
                            ) {
                              if (ctrl.namaBankCtrl.text.isNotEmpty &&
                                  textEditingController.text.isEmpty) {
                                textEditingController.text =
                                    ctrl.namaBankCtrl.text;
                              }
                              return TextFormField(
                                controller: textEditingController,
                                focusNode: focusNode,
                                decoration: const InputDecoration(
                                  hintText: 'Ketik nama KCU/KCP Bank...',
                                ),
                                onChanged: (val) =>
                                    ctrl.namaBankCtrl.text = val,
                              );
                            },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(16),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: isDesktop ? 520 : 320,
                                  maxHeight: 240,
                                ),
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final option = options.elementAt(index);
                                    return ListTile(
                                      title: Text(option['namaBank']),
                                      subtitle: Text(
                                        'PIC: ${option['namaPic']}',
                                      ),
                                      onTap: () => onSelected(option),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    _LabeledField(
                      label: 'PIC Bank',
                      child: TextFormField(
                        controller: ctrl.picBankCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Nama PIC Bank terkait',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _SectionLabel(
                title: 'Detail Order',
                caption:
                    'Informasi order, jenis pekerjaan, dan referensi covernote.',
              ),
              SiraSolidCard(
                child: Column(
                  children: [
                    _LabeledField(
                      label: 'No. Surat Order',
                      child: TextFormField(
                        controller: ctrl.noSuratOrderCtrl,
                        decoration: const InputDecoration(
                          hintText: 'R06.UM.GKD/0004/2026',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    _LabeledField(
                      label: 'Tanggal Order',
                      child: _DateField(
                        text: ctrl.tanggalOrder != null
                            ? DateFormat(
                                'dd MMM yyyy',
                              ).format(ctrl.tanggalOrder!)
                            : 'Pilih tanggal order',
                        isFilled: ctrl.tanggalOrder != null,
                        onTap: () => _pilihTanggal(
                          context,
                          ctrl.tanggalOrder,
                          (dt) async => ctrl.setTanggalOrder(dt),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    _LabeledField(
                      label: 'Jenis',
                      child: DropdownButtonFormField<String>(
                        initialValue:
                            [
                              'Hak Tanggungan',
                              'Lainnya',
                              'Fidusia',
                            ].contains(ctrl.jenisCtrl.text)
                            ? ctrl.jenisCtrl.text
                            : null,
                        items: const ['Hak Tanggungan', 'Lainnya', 'Fidusia']
                            .map(
                              (val) => DropdownMenuItem<String>(
                                value: val,
                                child: Text(val),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) ctrl.jenisCtrl.text = val;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Pilih jenis order',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    _LabeledField(
                      label: 'Rincian Order',
                      child: TextFormField(
                        controller: ctrl.rincianOrderCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'SHM No. 00037/Desa Mekarbakti...',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    _LabeledField(
                      label: 'No. Covernote',
                      child: TextFormField(
                        controller: ctrl.noCovernoteCtrl,
                        decoration: const InputDecoration(
                          hintText: 'XX/NTR/X/20XX',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _SectionLabel(
                title: 'Finansial',
                caption:
                    'Pastikan nominal terisi konsisten untuk kebutuhan monitoring.',
              ),
              SiraSolidCard(
                child: Column(
                  children: [
                    _CurrencyField(
                      label: 'Limit / Plafon',
                      controller: ctrl.limitPlafonCtrl,
                    ),
                    const SizedBox(height: AppSpacing.base),
                    _CurrencyField(
                      label: 'Nilai HT',
                      controller: ctrl.nilaiHTCtrl,
                    ),
                    const SizedBox(height: AppSpacing.base),
                    _CurrencyField(
                      label: 'Biaya Notaris',
                      controller: ctrl.biayaNotarisCtrl,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _SectionLabel(
                title: 'Pelaksanaan & SLA',
                caption:
                    'Nilai otomatis tetap dipertahankan dari logic controller saat ini.',
              ),
              SiraSolidCard(
                child: Column(
                  children: [
                    _LabeledField(
                      label: 'Tanggal Pelaksanaan',
                      child: _ReadOnlyField(
                        text: ctrl.tanggalPelaksanaan != null
                            ? DateFormat(
                                'dd MMM yyyy',
                              ).format(ctrl.tanggalPelaksanaan!)
                            : 'Otomatis mengikuti tanggal order',
                        icon: Icons.lock_outline_rounded,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    _LabeledField(
                      label: 'Batas SLA Laporan',
                      child: _ReadOnlyField(
                        text: ctrl.batasSlaCtrl.text.isEmpty
                            ? 'Dihitung otomatis'
                            : ctrl.batasSlaCtrl.text,
                        icon: Icons.lock_outline_rounded,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    _LabeledField(
                      label: 'Umur Pekerjaan',
                      child: _ReadOnlyField(
                        text: ctrl.umurPekerjaanCtrl.text.isEmpty
                            ? 'Dihitung otomatis'
                            : ctrl.umurPekerjaanCtrl.text,
                        icon: Icons.lock_outline_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _SectionLabel(
                title: 'Progres & BAST',
                caption:
                    'Status dan perkembangan akhir untuk memudahkan tindak lanjut.',
              ),
              SiraSolidCard(
                child: Column(
                  children: [
                    _LabeledField(
                      label: 'Progres Pekerjaan (Status)',
                      child: DropdownButtonFormField<String>(
                        initialValue:
                            AppConstants.listStatusPekerjaan.contains(
                              ctrl.statusPekerjaan,
                            )
                            ? ctrl.statusPekerjaan
                            : null,
                        items: AppConstants.listStatusPekerjaan
                            .map(
                              (val) => DropdownMenuItem<String>(
                                value: val,
                                child: Text(val),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) ctrl.setStatusPekerjaan(val);
                        },
                        decoration: const InputDecoration(
                          hintText: 'Pilih status pekerjaan',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    _LabeledField(
                      label: 'Progres Terakhir / Keterangan',
                      child: TextFormField(
                        controller: ctrl.progresDetailCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Contoh: SKMHT, selesai cetak, dll',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    _LabeledField(
                      label: 'Tanggal BAST',
                      child: _DateField(
                        text: ctrl.tanggalBast != null
                            ? DateFormat(
                                'dd MMM yyyy',
                              ).format(ctrl.tanggalBast!)
                            : 'Pilih tanggal BAST',
                        isFilled: ctrl.tanggalBast != null,
                        onTap: () => _pilihTanggal(
                          context,
                          ctrl.tanggalBast,
                          ctrl.setTanggalBast,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _SectionLabel(
                title: 'Catatan Tambahan',
                caption:
                    'Tambahkan konteks yang membantu tim saat menindaklanjuti berkas.',
              ),
              SiraSolidCard(
                child: Column(
                  children: [
                    _LabeledField(
                      label: 'Kekurangan Berkas',
                      child: TextFormField(
                        controller: ctrl.kekuranganCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Contoh: CLEAR, kurang KTP, dll',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    _LabeledField(
                      label: 'Per Kasus (Notes)',
                      child: TextFormField(
                        controller: ctrl.notesCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Catatan tambahan terkait kasus debitur',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    _LabeledField(
                      label: 'PIC Internal (Akad)',
                      child: TextFormField(
                        controller: ctrl.picInternalCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Nama staf yang memegang berkas',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_saveError.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.base),
                Text(
                  _saveError,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              SiraPrimaryButton(
                label: ctrl.isEditMode ? 'Simpan perubahan' : 'Simpan data',
                icon: Icons.save_outlined,
                onPressed: _simpan,
                isLoading: ctrl.isLoading,
                expanded: true,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.caption});

  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(caption, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

class _CurrencyField extends StatelessWidget {
  const _CurrencyField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return _LabeledField(
      label: label,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [CurrencyFormatIdr()],
        decoration: const InputDecoration(hintText: '0', prefixText: 'Rp '),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.text,
    required this.isFilled,
    required this.onTap,
  });

  final String text;
  final bool isFilled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: const InputDecoration(
          suffixIcon: Icon(Icons.calendar_month_outlined),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isFilled ? AppColors.textPrimary : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(suffixIcon: Icon(icon)),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color:
              text == 'Dihitung otomatis' ||
                  text == 'Otomatis mengikuti tanggal order'
              ? AppColors.textTertiary
              : AppColors.textPrimary,
        ),
      ),
    );
  }
}
