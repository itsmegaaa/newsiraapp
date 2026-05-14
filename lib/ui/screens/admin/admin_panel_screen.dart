// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../controllers/laporan_controller.dart';
import '../../../controllers/user_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/repositories/laporan_repository.dart';
import '../../layout/sira_responsive_shell.dart';
import '../../widgets/sira_glass_card.dart';
import '../../widgets/sira_primary_button.dart';
import '../../widgets/sira_secondary_button.dart';
import '../../widgets/sira_toast.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _roleFilter = 'SEMUA';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserProvider>();
    final repo = context.read<LaporanRepository>();
    final laporanCtrl = context.read<LaporanController>();
    final isDesktop = MediaQuery.of(context).size.width >= 980;

    if (!userProv.isAdmin) {
      return const _UnauthorizedAdminScreen();
    }

    return SiraResponsiveShell(
      title: 'Admin Panel',
      activeMenu: SiraMenu.adminPanel,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          SiraGlassCard(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: repo.streamUsers(),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                final activeUsers = docs.where((doc) {
                  return (doc.data()['isActive'] as bool? ?? true);
                }).length;
                final activeAdminCount = docs.where((doc) {
                  final data = doc.data();
                  return _normalizeRole(data['role']) == 'ADMIN' &&
                      (data['isActive'] as bool? ?? true);
                }).length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pusat kontrol admin SIRA',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Kelola pengguna, pantau sinkronisasi, dan buka alat operasional admin dari satu workspace yang lebih rapat dan mudah discan.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      spacing: AppSpacing.base,
                      runSpacing: AppSpacing.base,
                      children: [
                        _AdminOverviewTile(
                          label: 'Total Pengguna',
                          value: docs.length.toString(),
                          icon: Icons.groups_2_outlined,
                        ),
                        _AdminOverviewTile(
                          label: 'Pengguna Aktif',
                          value: activeUsers.toString(),
                          icon: Icons.verified_user_outlined,
                        ),
                        _AdminOverviewTile(
                          label: 'Admin Aktif',
                          value: activeAdminCount.toString(),
                          icon: Icons.admin_panel_settings_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      spacing: AppSpacing.base,
                      runSpacing: AppSpacing.base,
                      children: [
                        SizedBox(
                          width: isDesktop ? 220 : 180,
                          child: SiraPrimaryButton(
                            label: 'Sync Manual',
                            icon: Icons.sync_rounded,
                            onPressed: () => _showSyncDialog(
                              context,
                              userProv.email,
                              laporanCtrl,
                            ),
                            expanded: !isDesktop,
                          ),
                        ),
                        SizedBox(
                          width: isDesktop ? 180 : 168,
                          child: SiraPrimaryButton(
                            label: 'Tambah Bank',
                            icon: Icons.add_rounded,
                            onPressed: () => _tampilDialogBank(context),
                          ),
                        ),
                        SizedBox(
                          width: isDesktop ? 190 : 176,
                          child: SiraSecondaryButton(
                            label: 'Kelola Notaris',
                            icon: Icons.gavel_rounded,
                            onPressed: () => _tampilkanKelolaNotaris(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          StreamBuilder<DocumentSnapshot>(
            stream: repo.streamSyncStatus(),
            builder: (context, snapshot) {
              final data = snapshot.data?.data() as Map<String, dynamic>?;
              final isSyncing = data?['isSyncing'] == true;
              final lastSync = data?['lastSyncToSheet'] as Timestamp?;
              final lastError = data?['lastError'] as String?;

              return SiraGlassCard(
                subtle: true,
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Operasional',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.base,
                      runSpacing: AppSpacing.base,
                      children: [
                        _AdminMetric(
                          label: 'Status Sync',
                          value: isSyncing ? 'Sedang berjalan' : 'Siap',
                          icon: isSyncing
                              ? Icons.sync_rounded
                              : Icons.verified_outlined,
                        ),
                        _AdminMetric(
                          label: 'Sync Terakhir',
                          value: lastSync == null
                              ? 'Belum ada'
                              : DateFormat(
                                  'dd MMM yyyy, HH:mm',
                                ).format(lastSync.toDate()),
                          icon: Icons.schedule_outlined,
                        ),
                        _AdminMetric(
                          label: 'Error Terakhir',
                          value: (lastError == null || lastError.isEmpty)
                              ? 'Tidak ada'
                              : lastError,
                          icon: Icons.report_gmailerrorred_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.base),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: repo.streamUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Terjadi kesalahan saat memuat data pengguna.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];
              final activeAdminCount = docs.where((doc) {
                final data = doc.data();
                return _normalizeRole(data['role']) == 'ADMIN' &&
                    (data['isActive'] as bool? ?? true);
              }).length;

              final filteredDocs = docs.where((doc) {
                final data = doc.data();
                final nama = (data['nama'] as String? ?? '').toLowerCase();
                final email = (data['email'] as String? ?? doc.id)
                    .toLowerCase();
                final role = _normalizeRole(data['role']);

                final matchesSearch =
                    _searchQuery.isEmpty ||
                    nama.contains(_searchQuery) ||
                    email.contains(_searchQuery);
                final matchesRole =
                    _roleFilter == 'SEMUA' || role == _roleFilter;
                return matchesSearch && matchesRole;
              }).toList()
                ..sort((a, b) {
                  final nameA =
                      (a.data()['nama'] as String? ?? a.id).toLowerCase();
                  final nameB =
                      (b.data()['nama'] as String? ?? b.id).toLowerCase();
                  return nameA.compareTo(nameB);
                });

              return SizedBox(
                height: isDesktop ? 560 : 760,
                child: SiraGlassCard(
                  subtle: true,
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manajemen Pengguna',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${filteredDocs.length} dari ${docs.length} pengguna terlihat pada filter saat ini.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.base),
                      Wrap(
                        spacing: AppSpacing.base,
                        runSpacing: AppSpacing.base,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(
                            width: isDesktop ? 320 : 280,
                            child: TextField(
                              controller: _searchCtrl,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value.trim().toLowerCase();
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: 'Cari pengguna',
                                hintText: 'Nama atau email',
                                prefixIcon: Icon(Icons.search_rounded),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 220,
                            child: DropdownButtonFormField<String>(
                              initialValue: _roleFilter,
                              decoration: const InputDecoration(
                                labelText: 'Filter role',
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'SEMUA',
                                  child: Text('Semua'),
                                ),
                                DropdownMenuItem(
                                  value: 'ADMIN',
                                  child: Text('Admin'),
                                ),
                                DropdownMenuItem(
                                  value: 'STAFF',
                                  child: Text('Staff'),
                                ),
                                DropdownMenuItem(
                                  value: 'VIEWER',
                                  child: Text('Viewer'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _roleFilter = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.base),
                      if (isDesktop) const _UserTableHeader(),
                      if (isDesktop) const SizedBox(height: AppSpacing.sm),
                      Expanded(
                        child: filteredDocs.isEmpty
                            ? const _EmptyUsersState()
                            : ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: filteredDocs.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: AppSpacing.sm),
                                itemBuilder: (context, index) {
                                  final doc = filteredDocs[index];
                                  return _UserCard(
                                    data: doc.data(),
                                    docId: doc.id,
                                    currentUserEmail: userProv.email,
                                    activeAdminCount: activeAdminCount,
                                    onChangeRole: (newRole) => _changeRole(
                                      context: context,
                                      doc: doc,
                                      newRole: newRole,
                                      activeAdminCount: activeAdminCount,
                                      currentUserEmail: userProv.email,
                                    ),
                                    onToggleActive: (newStatus) =>
                                        _toggleUserActive(
                                          context: context,
                                          doc: doc,
                                          newStatus: newStatus,
                                          activeAdminCount: activeAdminCount,
                                          currentUserEmail: userProv.email,
                                        ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.base),
          _InlineMasterBankSection(
            onEditBank: (doc) => _tampilDialogBank(context, doc: doc),
            onHapusBank: (id) => _konfirmasiHapusBank(context, repo, id),
          ),
          const SizedBox(height: AppSpacing.base),
          const _InlineLogSection(),
          ],
        ),
      ),
    );
  }

  String _normalizeRole(dynamic value) {
    return (value as String? ?? 'STAFF').toUpperCase();
  }

  Future<void> _changeRole({
    required BuildContext context,
    required QueryDocumentSnapshot<Map<String, dynamic>> doc,
    required String newRole,
    required int activeAdminCount,
    required String currentUserEmail,
  }) async {
    final data = doc.data();
    final email = (data['email'] as String? ?? doc.id).trim();
    final currentRole = _normalizeRole(data['role']);
    final isActive = data['isActive'] as bool? ?? true;

    if (currentRole == newRole) return;

    if (email == currentUserEmail && newRole != 'ADMIN') {
      SiraToast.show(
        context,
        type: SiraToastType.error,
        message: 'Akun admin yang sedang dipakai tidak bisa diturunkan rolenya.',
      );
      return;
    }

    if (currentRole == 'ADMIN' &&
        newRole != 'ADMIN' &&
        isActive &&
        activeAdminCount <= 1) {
      SiraToast.show(
        context,
        type: SiraToastType.error,
        message: 'Minimal satu admin aktif harus tetap tersedia.',
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Role Pengguna'),
        content: Text(
          'Ubah role $email dari $currentRole menjadi $newRole?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Simpan',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await context.read<LaporanRepository>().updateUserRole(doc.id, newRole);

    if (!context.mounted) return;
    SiraToast.show(
      context,
      type: SiraToastType.success,
      message: 'Role pengguna berhasil diperbarui.',
    );
  }

  Future<void> _toggleUserActive({
    required BuildContext context,
    required QueryDocumentSnapshot<Map<String, dynamic>> doc,
    required bool newStatus,
    required int activeAdminCount,
    required String currentUserEmail,
  }) async {
    final data = doc.data();
    final email = (data['email'] as String? ?? doc.id).trim();
    final role = _normalizeRole(data['role']);

    if (email == currentUserEmail && !newStatus) {
      SiraToast.show(
        context,
        type: SiraToastType.error,
        message: 'Akun yang sedang dipakai tidak bisa dinonaktifkan.',
      );
      return;
    }

    if (role == 'ADMIN' && !newStatus && activeAdminCount <= 1) {
      SiraToast.show(
        context,
        type: SiraToastType.error,
        message: 'Minimal satu admin aktif harus tetap tersedia.',
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(newStatus ? 'Aktifkan Pengguna' : 'Nonaktifkan Pengguna'),
        content: Text(
          newStatus
              ? 'Aktifkan kembali akun $email?'
              : 'Nonaktifkan akun $email dari panel admin?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              newStatus ? 'Aktifkan' : 'Nonaktifkan',
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await context.read<LaporanRepository>().updateUserActiveStatus(
      doc.id,
      newStatus,
    );

    if (!context.mounted) return;
    SiraToast.show(
      context,
      type: SiraToastType.success,
      message: newStatus
          ? 'Pengguna berhasil diaktifkan.'
          : 'Pengguna berhasil dinonaktifkan.',
    );
  }

  Future<void> _showSyncDialog(
    BuildContext context,
    String email,
    LaporanController ctrl,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sinkronisasi Manual'),
        content: const Text(
          'Kirim data laporan terbaru ke Google Sheet sekarang?',
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

    if (confirmed != true) return;

    await ctrl.triggerSyncManual(email);
    if (!context.mounted) return;
    SiraToast.show(
      context,
      type: SiraToastType.success,
      message: 'Permintaan sinkronisasi berhasil dikirim.',
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
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
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
          ),
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

  void _konfirmasiHapusBank(
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

class _InlineMasterBankSection extends StatelessWidget {
  const _InlineMasterBankSection({
    required this.onEditBank,
    required this.onHapusBank,
  });

  final ValueChanged<DocumentSnapshot> onEditBank;
  final ValueChanged<String> onHapusBank;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<LaporanRepository>();
    final isDesktop = MediaQuery.of(context).size.width >= 980;

    return SizedBox(
      height: isDesktop ? 520 : 640,
      child: SiraGlassCard(
        subtle: true,
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Master Bank',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Kelola daftar KCU/KCP bank dan PIC yang dipakai di form laporan langsung dari admin panel.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: repo.streamMasterBank(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Terjadi kesalahan saat memuat data bank.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text('Belum ada data bank.'));
                  }

                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: docs.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final namaPic = doc['namaPic'].toString();
                      return SiraGlassCard(
                        tone: SiraGlassTone.metric,
                        padding: const EdgeInsets.all(AppSpacing.base),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.account_balance_outlined,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doc['namaBank'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    namaPic.isEmpty
                                        ? 'PIC belum diisi'
                                        : 'PIC: $namaPic',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') onEditBank(doc);
                                if (value == 'delete') onHapusBank(doc.id);
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
                          ],
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
    );
  }
}

class _InlineLogSection extends StatelessWidget {
  const _InlineLogSection();

  @override
  Widget build(BuildContext context) {
    final repo = context.read<LaporanRepository>();
    final isDesktop = MediaQuery.of(context).size.width >= 980;

    return SizedBox(
      height: isDesktop ? 520 : 620,
      child: SiraGlassCard(
        subtle: true,
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Log Aktivitas',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Pantau perubahan terbaru tanpa keluar dari admin panel.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            Expanded(
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    );
                  }

                  final logs = snapshot.data?.docs ?? [];
                  if (logs.isEmpty) {
                    return const Center(
                      child: Text('Belum ada riwayat aktivitas.'),
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: logs.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final data = logs[index].data() as Map<String, dynamic>;
                      return _InlineLogCard(data: data);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineLogCard extends StatelessWidget {
  const _InlineLogCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final aksi = data['aksi'] as String? ?? 'UNKNOWN';
    final detail = data['detail'] as String? ?? '-';
    final oleh = data['oleh'] as String? ?? 'Sistem';
    final waktu = data['waktu'] as Timestamp?;
    final semantic = _semanticForAction(aksi);

    return SiraGlassCard(
      tone: SiraGlassTone.metric,
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: semantic.softColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(semantic.icon, color: semantic.color, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      aksi,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: semantic.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      waktu == null
                          ? '-'
                          : DateFormat(
                              'dd MMM yyyy, HH:mm',
                            ).format(waktu.toDate()),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  oleh,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
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

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.data,
    required this.docId,
    required this.currentUserEmail,
    required this.activeAdminCount,
    required this.onChangeRole,
    required this.onToggleActive,
  });

  final Map<String, dynamic> data;
  final String docId;
  final String currentUserEmail;
  final int activeAdminCount;
  final ValueChanged<String> onChangeRole;
  final ValueChanged<bool> onToggleActive;

  @override
  Widget build(BuildContext context) {
    final name = data['nama'] as String? ?? 'Tanpa Nama';
    final email = (data['email'] as String? ?? docId).trim();
    final role = (data['role'] as String? ?? 'STAFF').toUpperCase();
    final isActive = data['isActive'] as bool? ?? true;
    final createdAt = data['createdAt'] as Timestamp?;
    final updatedAt = data['updatedAt'] as Timestamp?;
    final isCurrentUser = email == currentUserEmail;
    final roleColor = role == 'ADMIN'
        ? AppColors.primary
        : role == 'VIEWER'
        ? AppColors.warning
        : AppColors.info;

    return SiraGlassCard(
      subtle: true,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 880;

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primarySoft
                              : AppColors.surfaceL3,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _StatusChip(label: role, color: roleColor),
                          _StatusChip(
                            label: isActive ? 'Aktif' : 'Nonaktif',
                            color: isActive
                                ? AppColors.success
                                : AppColors.textTertiary,
                          ),
                          if (isCurrentUser)
                            const _StatusChip(
                              label: 'Akun Saya',
                              color: AppColors.accentPurple,
                            ),
                        ],
                      ),
                      if (role == 'ADMIN' && activeAdminCount <= 1 && isActive)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Text(
                            'Admin aktif terakhir',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MetaText(
                        label: 'Dibuat',
                        value: _formatTimestamp(createdAt),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _MetaText(
                        label: 'Diupdate',
                        value: _formatTimestamp(updatedAt),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: role,
                          decoration: const InputDecoration(
                            labelText: 'Role',
                            isDense: true,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'ADMIN',
                              child: Text('Admin'),
                            ),
                            DropdownMenuItem(
                              value: 'STAFF',
                              child: Text('Staff'),
                            ),
                            DropdownMenuItem(
                              value: 'VIEWER',
                              child: Text('Viewer'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            onChangeRole(value);
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Aktif',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          Switch(
                            value: isActive,
                            onChanged: onToggleActive,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primarySoft
                          : AppColors.surfaceL3,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _StatusChip(label: role, color: roleColor),
                  _StatusChip(
                    label: isActive ? 'Aktif' : 'Nonaktif',
                    color: isActive
                        ? AppColors.success
                        : AppColors.textTertiary,
                  ),
                  if (isCurrentUser)
                    const _StatusChip(
                      label: 'Akun Saya',
                      color: AppColors.accentPurple,
                    ),
                ],
              ),
              if (role == 'ADMIN' && activeAdminCount <= 1 && isActive)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    'Admin aktif terakhir',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.base,
                runSpacing: AppSpacing.xs,
                children: [
                  _MetaText(
                    label: 'Dibuat',
                    value: _formatTimestamp(createdAt),
                  ),
                  _MetaText(
                    label: 'Diupdate',
                    value: _formatTimestamp(updatedAt),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.base,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<String>(
                      initialValue: role,
                      decoration: const InputDecoration(
                        labelText: 'Role pengguna',
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'ADMIN', child: Text('Admin')),
                        DropdownMenuItem(value: 'STAFF', child: Text('Staff')),
                        DropdownMenuItem(
                          value: 'VIEWER',
                          child: Text('Viewer'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        onChangeRole(value);
                      },
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Aktif',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Switch(
                        value: isActive,
                        onChanged: onToggleActive,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  static String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '-';
    return DateFormat('dd MMM yyyy, HH:mm').format(timestamp.toDate());
  }
}

class _UserTableHeader extends StatelessWidget {
  const _UserTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'Pengguna',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Status',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Waktu',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Kontrol',
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        ),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

class _AdminMetric extends StatelessWidget {
  const _AdminMetric({
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
      constraints: const BoxConstraints(minWidth: 210, maxWidth: 320),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
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

class _AdminOverviewTile extends StatelessWidget {
  const _AdminOverviewTile({
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
      width: 180,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
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

class _EmptyUsersState extends StatelessWidget {
  const _EmptyUsersState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Tidak ada pengguna yang cocok dengan filter saat ini.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _UnauthorizedAdminScreen extends StatelessWidget {
  const _UnauthorizedAdminScreen();

  @override
  Widget build(BuildContext context) {
    return SiraResponsiveShell(
      title: 'Admin Panel',
      activeMenu: SiraMenu.dashboard,
      child: Center(
        child: SiraGlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 52,
                color: AppColors.warning,
              ),
              const SizedBox(height: AppSpacing.base),
              Text(
                'Akses admin diperlukan',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Halaman ini hanya tersedia untuk akun admin aktif.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
