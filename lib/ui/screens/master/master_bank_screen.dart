import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/laporan_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../layout/sira_responsive_shell.dart';
import '../../widgets/sira_primary_button.dart';
import '../../widgets/sira_secondary_button.dart';
import '../../widgets/sira_solid_card.dart';
import '../../widgets/sira_toast.dart';

class MasterBankScreen extends StatelessWidget {
  const MasterBankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<LaporanRepository>();

    return SiraResponsiveShell(
      title: 'Master Data Bank',
      activeMenu: SiraMenu.masterBank,
      actions: [
        IconButton(
          tooltip: 'Tambah bank',
          onPressed: () => _tampilDialogBank(context),
          icon: const Icon(Icons.add_rounded),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Kelola daftar KCU/KCP bank dan PIC yang dipakai di form laporan.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Wrap(
            spacing: AppSpacing.base,
            runSpacing: AppSpacing.base,
            children: [
              SiraPrimaryButton(
                label: 'Tambah Bank',
                icon: Icons.add_rounded,
                onPressed: () => _tampilDialogBank(context),
              ),
              SiraSecondaryButton(
                label: 'Kelola Notaris',
                icon: Icons.gavel_rounded,
                onPressed: () => _tampilkanKelolaNotaris(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: repo.streamMasterBank(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Terjadi kesalahan saat memuat data bank.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const _EmptyMasterState();
                }

                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final namaPic = doc['namaPic'].toString();
                    return SiraSolidCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.account_balance_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        title: Text(
                          doc['namaBank'],
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          namaPic.isEmpty ? 'PIC belum diisi' : 'PIC: $namaPic',
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _tampilDialogBank(context, doc: doc);
                            }
                            if (value == 'delete') {
                              _konfirmasiHapus(context, repo, doc.id);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Hapus'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _tampilDialogBank(BuildContext context, {DocumentSnapshot? doc}) {
    final repo = context.read<LaporanRepository>();
    final bankCtrl = TextEditingController(
      text: doc != null ? doc['namaBank'] : '',
    );
    final picCtrl = TextEditingController(
      text: doc != null ? doc['namaPic'] : '',
    );

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(doc == null ? 'Tambah Bank' : 'Edit Bank'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: bankCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Nama KCU/KCP Bank',
                hintText: 'Contoh: KCP GARUT CILEDUG',
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            TextField(
              controller: picCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama PIC Bank',
                hintText: 'Masukkan nama PIC',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              if (bankCtrl.text.trim().isEmpty) return;
              final data = {
                'namaBank': bankCtrl.text.trim().toUpperCase(),
                'namaPic': picCtrl.text.trim(),
                'waktuUpdate': FieldValue.serverTimestamp(),
              };

              if (doc == null) {
                await repo.tambahBank(data);
              } else {
                await repo.updateBank(doc.id, data);
              }

              if (!ctx.mounted) return;
              Navigator.of(ctx).pop();
              SiraToast.show(
                context,
                type: SiraToastType.success,
                message: doc == null
                    ? 'Bank baru berhasil ditambahkan.'
                    : 'Data bank berhasil diperbarui.',
              );
            },
            child: const Text(
              'Simpan',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _konfirmasiHapus(
    BuildContext context,
    LaporanRepository repo,
    String id,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Data'),
        content: const Text('Data bank ini akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await repo.hapusBank(id);
              if (!ctx.mounted) return;
              Navigator.of(ctx).pop();
              SiraToast.show(
                context,
                type: SiraToastType.success,
                message: 'Data bank berhasil dihapus.',
              );
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _tampilkanKelolaNotaris(BuildContext context) {
    final repo = context.read<LaporanRepository>();
    final notarisBaruCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kelola Daftar Notaris'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: notarisBaruCtrl,
                decoration: InputDecoration(
                  hintText: 'Tambah nama notaris...',
                  suffixIcon: IconButton(
                    onPressed: () async {
                      if (notarisBaruCtrl.text.trim().isEmpty) return;
                      await repo.tambahNotaris(notarisBaruCtrl.text.trim());
                      notarisBaruCtrl.clear();
                    },
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              Flexible(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: repo.streamMasterNotaris(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      );
                    }
                    final data = snapshot.data?.data() as Map<String, dynamic>?;
                    final list = data != null && data['items'] is List
                        ? List<String>.from(data['items'] as List)
                        : <String>[];

                    if (list.isEmpty) {
                      return const Center(child: Text('Belum ada notaris.'));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];
                        return ListTile(
                          title: Text(item),
                          trailing: IconButton(
                            onPressed: () => repo.hapusNotaris(item),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.error,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

class _EmptyMasterState extends StatelessWidget {
  const _EmptyMasterState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_outlined,
            size: 72,
            color: AppColors.textTertiary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Belum ada data bank',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tambahkan master bank agar autocomplete form tetap akurat.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
