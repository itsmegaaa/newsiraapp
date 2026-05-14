// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import './form_order_screen.dart';
import './pengaturan_screen.dart';
import '../controllers/beranda_controller.dart';
// Import design system widgets and tokens
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_radius.dart';
import '../ui/layout/sira_responsive_shell.dart';
import '../ui/widgets/sira_glass_card.dart';
import '../ui/widgets/sira_solid_card.dart';
import '../ui/widgets/sira_status_badge.dart';
import '../ui/widgets/sira_primary_button.dart';
import '../ui/navigation/sira_page_route.dart';

class BerandaNotaris extends StatefulWidget {
  const BerandaNotaris({super.key});
  @override
  State<BerandaNotaris> createState() => _BerandaNotarisState();
}

class _BerandaNotarisState extends State<BerandaNotaris> {
  final BerandaController _controller = BerandaController();
  final TextEditingController _catatanCtrl = TextEditingController();
  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _connSub;

  @override
  void initState() {
    super.initState();
    _controller.inisialisasiData(); 
    _connSub = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if (mounted) {
        setState(() => _isOnline = !result.contains(ConnectivityResult.none));
      }
    });
  }

  void _tandaiSelesai(String idDokumen, String namaDebitur) async {
    try { await _controller.tandaiSelesai(idDokumen, namaDebitur); } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memperbarui status.')));
    }
  }

  void _hapusData(String idDokumen, String namaDebitur) async {
    try { await _controller.hapusData(idDokumen, namaDebitur); } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menghapus data.')));
    }
  }

  void _tambahHistori(String idDokumen) async {
    if (_catatanCtrl.text.trim().isEmpty) return;
    try {
      await _controller.tambahHistori(idDokumen, _catatanCtrl.text.trim());
      _catatanCtrl.clear();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menambah catatan.')));
    }
  }

  void _eksporDanBagikanCSV() async {
    try { await _controller.eksporDanBagikanCSV(); } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal ekspor data.')));
    }
  }

  void _imporExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['xlsx'],
);
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mengunggah data ke Cloud...')));
      try {
        int count = await _controller.imporExcel(result.files.single);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berhasil impor $count data!')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal impor Excel: $e')));
      }
    }
  }

  /// Builds an interactive statistic tile used in the dashboard hero. The
  /// [label] describes the metric (e.g. "Selesai"), [count] is the
  /// numeric value, [status] indicates whether this filter is currently
  /// selected, [color] controls the accent colour for the tile, and
  /// [onTap] is invoked when the tile is tapped. This widget uses
  /// design system tokens for spacing, colours and typography.
  Widget _buildStatTile({
    required String label,
    required int count,
    required bool status,
    required Color color,
    required VoidCallback onTap,
  }) {
    final bg = status ? color.withOpacity(0.1) : AppColors.surfaceL2;
    final borderCol = status ? color : AppColors.borderSubtle;
    final textCol = status ? color : AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.cardS),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.cardS),
          border: Border.all(color: borderCol),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count.toString(),
              style: AppTextStyles.headingSmall.copyWith(color: textCol),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label.toUpperCase(),
              style: AppTextStyles.bodySmall.copyWith(
                color: textCol,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Batalkan listener dan controller untuk mencegah memory leak
    _connSub?.cancel();
    _catatanCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Always use light mode tokens from the design system
    // Build the dashboard inside a SiraResponsiveShell. The title is the name of the
    // bank/dataset (for now hardcode "Beranda"). Navigation index 0 corresponds to
    // this screen, index 1 opens the pengaturan screen.
    return SiraResponsiveShell(
      title: 'Beranda',
      currentIndex: 0,
      onItemSelected: (index) async {
        if (index == 1) {
          // Navigate to pengaturan screen then refresh data when returning
          await Navigator.of(context).push(
            SiraPageRoute(builder: (c) => const HalamanPengaturan()),
          );
          if (mounted) {
            _controller.inisialisasiData();
          }
        }
      },
      actions: [
        // Import Excel
        IconButton(
          icon: const Icon(Icons.upload_file, color: AppColors.primary),
          tooltip: 'Import Excel',
          onPressed: _imporExcel,
        ),
        // Export options
        IconButton(
          icon: const Icon(Icons.ios_share, color: AppColors.primary),
          tooltip: 'Export',
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: SiraSolidCard(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.table_chart, color: AppColors.success),
                        title: const Text('Ekspor ke CSV (Excel)'),
                        onTap: () {
                          Navigator.pop(context);
                          _eksporDanBagikanCSV();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.picture_as_pdf, color: AppColors.error),
                        title: const Text('Ekspor ke PDF (Siap Cetak)'),
                        onTap: () {
                          Navigator.pop(context);
                          _controller.eksporDanBagikanPDF();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final List<Map<String, dynamic>> filteredData = _controller.filteredData;
          int totalSelesai = 0;
          int totalTelat = 0;
          int totalProses = 0;
          int totalApproval = 0;
          // Count metrics
          for (var item in _controller.daftarOrder) {
            final status = item['progres'];
            if (status == 'SELESAI') {
              totalSelesai++;
            } else if (status == 'MENUNGGU APPROVAL') {
              totalApproval++;
            } else if (_controller.cekTelat(item)) {
              totalTelat++;
            } else {
              totalProses++;
            }
          }

          // Show loading indicator
          if (_controller.sedangMemuat) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Offline banner
              if (!_isOnline)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  color: AppColors.error,
                  child: Center(
                    child: Text(
                      'Tidak Ada Koneksi Internet',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

              // Hero stats card
              SiraGlassCard(
                margin: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Statistik', style: AppTextStyles.headingMedium),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: [
                        if (_controller.userRole == 'ADMIN')
                          _buildStatTile(
                            label: 'Approval',
                            count: totalApproval,
                            status: _controller.filterStatus == 'APPROVAL',
                            color: AppColors.primary,
                            onTap: () => _controller.setFilterStatus('APPROVAL'),
                          ),
                        _buildStatTile(
                          label: 'Selesai',
                          count: totalSelesai,
                          status: _controller.filterStatus == 'SELESAI',
                          color: AppColors.success,
                          onTap: () => _controller.setFilterStatus('SELESAI'),
                        ),
                        _buildStatTile(
                          label: 'Proses',
                          count: totalProses,
                          status: _controller.filterStatus == 'PROSES',
                          color: AppColors.primary,
                          onTap: () => _controller.setFilterStatus('PROSES'),
                        ),
                        _buildStatTile(
                          label: 'Telat',
                          count: totalTelat,
                          status: _controller.filterStatus == 'TELAT',
                          color: AppColors.error,
                          onTap: () => _controller.setFilterStatus('TELAT'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Search field
              SiraSolidCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.sm,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
                    hintText: 'Cari Debitur, No Surat, atau KCU...',
                    hintStyle: AppTextStyles.bodyMedium,
                    border: InputBorder.none,
                  ),
                  onChanged: (v) => _controller.setKataKunci(v),
                ),
              ),

              // Content list
              Expanded(
                child: filteredData.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_off_outlined, size: 80, color: AppColors.borderSubtle),
                            const SizedBox(height: AppSpacing.base),
                            Text('Belum ada data / Tidak ditemukan', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) {
                          final item = filteredData[index];
                          final bool isSelesai = item['progres'] == 'SELESAI';
                          final bool isTelat = _controller.cekTelat(item);
                          final int sisaHari = _controller.hitungSisaHari(item);
                          final bool isMenunggu = item['progres'] == 'MENUNGGU APPROVAL';
                          final bool isHampirTelat = !isSelesai && !isTelat && sisaHari <= 3;
                          // Determine status badge
                          late SiraStatusBadge statusBadge;
                          if (isSelesai) {
                            statusBadge = SiraStatusBadge(text: 'SELESAI', status: SiraStatus.success, small: true);
                          } else if (isMenunggu) {
                            statusBadge = SiraStatusBadge(text: 'MENUNGGU', status: SiraStatus.info, small: true);
                          } else if (isTelat) {
                            statusBadge = SiraStatusBadge(text: 'TELAT', status: SiraStatus.error, small: true);
                          } else if (isHampirTelat) {
                            statusBadge = SiraStatusBadge(text: 'H-$sisaHari', status: SiraStatus.warning, small: true);
                          } else {
                            statusBadge = SiraStatusBadge(text: item['progres'], status: SiraStatus.info, small: true);
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.base),
                            child: GestureDetector(
                              onTap: () => _tampilkanDetail(item),
                              onLongPress: isSelesai
                                  ? null
                                  : () {
                                      // Show confirm finish dialog
                                      showDialog(
                                        context: context,
                                        builder: (c) => AlertDialog(
                                          title: const Text('Tandai Selesai?', style: TextStyle(fontWeight: FontWeight.bold)),
                                          content: Text('Berkas debitur ${item['debitur']} sudah beres?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(c),
                                              child: const Text('BATAL', style: TextStyle(color: Colors.grey)),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                                              onPressed: () {
                                                Navigator.pop(c);
                                                _tandaiSelesai(item['id'], item['debitur']);
                                              },
                                              child: const Text('YA, SELESAI'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                              child: Dismissible(
                                key: ValueKey(item['id']?.toString() ?? ''),
                                direction: _controller.userRole == 'ADMIN' ? DismissDirection.endToStart : DismissDirection.none,
                                background: Container(
                                  margin: const EdgeInsets.only(bottom: AppSpacing.base),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(AppRadius.cardM),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: AppSpacing.xl),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text('HAPUS', style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
                                      const SizedBox(width: AppSpacing.sm),
                                      const Icon(Icons.delete_sweep, color: Colors.white, size: 24),
                                    ],
                                  ),
                                ),
                                confirmDismiss: (d) async {
                                  final res = await showDialog(
                                    context: context,
                                    builder: (c) => AlertDialog(
                                      title: const Text('Hapus?', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                      content: Text('Hapus berkas atas nama ${item['debitur']}?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(c, false),
                                          child: const Text('BATAL', style: TextStyle(color: Colors.grey)),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                                          onPressed: () => Navigator.pop(c, true),
                                          child: const Text('HAPUS'),
                                        ),
                                      ],
                                    ),
                                  );
                                  return res;
                                },
                                onDismissed: (d) => _hapusData(item['id'], item['debitur']),
                                child: SiraSolidCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              (item['debitur']?.toString() ?? '').toUpperCase(),
                                              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          statusBadge,
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      Row(
                                        children: [
                                          const Icon(Icons.folder_open, size: 14, color: AppColors.textTertiary),
                                          const SizedBox(width: AppSpacing.xs),
                                          Expanded(
                                            child: Text(
                                              '${item['noSurat']} • ${item['jenis']}',
                                              style: AppTextStyles.bodySmall,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Row(
                                        children: [
                                          const Icon(Icons.account_balance, size: 14, color: AppColors.textTertiary),
                                          const SizedBox(width: AppSpacing.xs),
                                          Expanded(
                                            child: Text(
                                              '${item['kcu']} • PIC Bank: ${item['picBank']}',
                                              style: AppTextStyles.bodySmall,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      const Divider(height: 1),
                                      const SizedBox(height: AppSpacing.sm),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.person, size: 14, color: AppColors.textTertiary),
                                              const SizedBox(width: AppSpacing.xs),
                                              Text(
                                                item['picInternal'] ?? 'Belum ada',
                                                style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          isSelesai
                                              ? Row(
                                                  children: [
                                                    const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                                                    const SizedBox(width: AppSpacing.xs),
                                                    Text('Selesai', style: AppTextStyles.bodySmall.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                                                  ],
                                                )
                                              : Row(
                                                  children: [
                                                    const Icon(Icons.calendar_today, size: 14, color: AppColors.textTertiary),
                                                    const SizedBox(width: AppSpacing.xs),
                                                    Text(
                                                      _formatTanggal(item['deadline']),
                                                      style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: isTelat ? AppColors.error : AppColors.textPrimary),
                                                    ),
                                                    if (!isMenunggu) ...[
                                                      const SizedBox(width: AppSpacing.sm),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                                                        decoration: BoxDecoration(
                                                          color: isTelat ? AppColors.error : AppColors.surfaceL2,
                                                          borderRadius: BorderRadius.circular(AppRadius.cardS),
                                                        ),
                                                        child: Text(
                                                          '${DateTime.now().difference(DateTime.parse(item['tglOrder'])).inDays}h',
                                                          style: AppTextStyles.bodySmall.copyWith(
                                                            fontWeight: FontWeight.bold,
                                                            color: isTelat ? Colors.white : AppColors.textPrimary,
                                                          ),
                                                        ),
                                                      ),
                                                    ]
                                                  ],
                                                ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Floating action button to add data
              const SizedBox(height: AppSpacing.xl),
              if (_controller.userRole == 'ADMIN')
                Align(
                  alignment: Alignment.centerRight,
                  child: SiraPrimaryButton(
                    label: 'Tambah Data',
                    onPressed: () async {
                      final res = await Navigator.of(context).push(
                        SiraPageRoute(
                          builder: (context) => FormOrderScreen(
                            targetSLADefault: _controller.targetSLA,
                            userRole: _controller.userRole,
                          ),
                        ),
                      );
                      if (res != null) {
                        await _controller.simpanOrder(res);
                      }
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _tampilkanDetail(Map<String, dynamic> item) {
    String umurStr = item['progres'] == 'SELESAI' ? 'SELESAI' : '${DateTime.now().difference(DateTime.parse(item['tglOrder'])).inDays} Hari';

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(25))),
        padding: EdgeInsets.only(top: 12, left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(children: [
          Center(child: Container(width: 40, height: 5, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Detail Order', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            Row(children: [
              IconButton(icon: const Icon(Icons.share, color: Colors.green), onPressed: () { Share.share("📄 *DETAIL ORDER NOTARIS*\n\n👤 *Debitur:* ${item['debitur']}\n🏦 *KCU/KCP:* ${item['kcu']}\n⚖️ *Notaris:* ${item['notaris']}"); }),
              ElevatedButton.icon(icon: const Icon(Icons.edit, size: 16), label: const Text('Edit'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                onPressed: () async {
                  Navigator.pop(context);
                  final res = await Navigator.push(context, MaterialPageRoute(builder: (context) => FormOrderScreen(dataAwal: item, targetSLADefault: _controller.targetSLA, userRole: _controller.userRole)));
                  if (res != null) { await _controller.simpanOrder(res); }
                }
              ),
            ]),
          ]),
          const Divider(height: 30),

          if (item['progres'] == 'MENUNGGU APPROVAL' && _controller.userRole == 'ADMIN')
            Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton.icon(icon: const Icon(Icons.check_circle_outline, size: 24), label: const Text('APPROVE BERKAS INI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.purple, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  Navigator.pop(context);
                  try { await _controller.approveBerkas(item['id'], item['debitur']); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berkas berhasil di-Approve!'), backgroundColor: Colors.green)); } catch (e) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal melakukan Approve!'))); }
                },
              ),
            ),

          Expanded(child: ListView(children: [
            _barisDetail('Debitur', item['debitur']), _barisDetail('Notaris', item['notaris']), _barisDetail('KCU/KCP', item['kcu']),
            _barisDetail('PIC Bank', item['picBank']), _barisDetail('No Surat', item['noSurat']), _barisDetail('No Covernote', item['covernote']),
            _barisDetail('Jenis', item['jenis']), _barisDetail('Rincian', item['rincian']), const Divider(),
            _barisDetail('Limit', 'Rp ${_formatRupiah(item['limit'])}'), _barisDetail('Nilai HT', 'Rp ${_formatRupiah(item['nilaiHT'])}'),
            _barisDetail('Biaya Notaris', 'Rp ${_formatRupiah(item['biaya'])}'), const Divider(),
            _barisDetail('Tgl Order', _formatTanggal(item['tglOrder'])), _barisDetail('Tgl Pelaksanaan', _formatTanggal(item['tglPelaksanaan'])),
            _barisDetail('Deadline SLA', _formatTanggal(item['deadline'])), _barisDetail('Umur Pekerjaan', umurStr),
            _barisDetail('Progres', item['progres']), _barisDetail('Progres/Ket', item['progresKeterangan']),
            _barisDetail('Tgl BAST', _formatTanggal(item['tglBAST'])), _barisDetail('Catatan', item['perKasus']),
            _barisDetail('Kekurangan', item['note']), const Divider(thickness: 2),
            const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('Update Kendala:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent))),
            Row(children: [
              Expanded(child: TextField(controller: _catatanCtrl, decoration: InputDecoration(hintText: 'Ketik update...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), isDense: true))),
              const SizedBox(width: 8), CircleAvatar(backgroundColor: Colors.blueAccent, child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 20), onPressed: () => _tambahHistori(item['id'])))
            ]),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('data_notaris').doc(item['id']).collection('histori').orderBy('waktu', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                var docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) return const Text('Belum ada histori.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
                return ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: docs.length, itemBuilder: (context, index) {
                  var doc = docs[index].data() as Map<String, dynamic>;
                  DateTime? tgl = (doc['waktu'] as Timestamp?)?.toDate();
                  return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.withOpacity(0.2))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(tgl != null ? DateFormat('dd MMM yyyy • HH:mm').format(tgl) : 'Baru', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)), const SizedBox(height: 6), Text(doc['teks'] ?? '-', style: const TextStyle(fontSize: 14))]));
                });
              },
            ),
            const SizedBox(height: 20), _barisDetail('PIC Akad', item['picInternal']),
          ]))
        ]),
      ),
    );
  }

  Widget _barisDetail(String label, dynamic nilai) => Padding(padding: const EdgeInsets.symmetric(vertical: 4.0), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))), const Text(' :  ', style: TextStyle(color: Colors.grey)), Expanded(child: Text(nilai?.toString() ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)))]));
  String _formatTanggal(String? isoString, {String fallback = '-'}) { if (isoString == null || isoString.isEmpty) return fallback; try { return DateFormat('dd/MM/yyyy').format(DateTime.parse(isoString)); } catch (e) { return fallback; } }
  String _formatRupiah(String? angkaString) { if (angkaString == null || angkaString.isEmpty) return '0'; try { return NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(angkaString)); } catch (e) { return angkaString; } }
}