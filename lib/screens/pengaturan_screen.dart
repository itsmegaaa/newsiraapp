// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' hide Border;

import 'package:firebase_auth/firebase_auth.dart';

// Import design system tokens and widgets
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_radius.dart';
import '../ui/layout/sira_responsive_shell.dart';
import '../ui/widgets/sira_solid_card.dart';

class HalamanPengaturan extends StatefulWidget {
  const HalamanPengaturan({super.key});
  @override
  State<HalamanPengaturan> createState() => _HalamanPengaturanState();
}

class _HalamanPengaturanState extends State<HalamanPengaturan> {
  int _targetSLA = 30;
  String userRole = 'STAFF';

  @override
  void initState() {
    super.initState();
    _muatPengaturan();
    _cekRoleUser();
  }

  Future<void> _muatPengaturan() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _targetSLA = prefs.getInt('target_sla') ?? 30;
    });
  }

  Future<void> _cekRoleUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.email).get();
        if (doc.exists) {
          final data = doc.data();
          if (data != null) {
            setState(() {
              userRole = data['role'] ?? 'STAFF';
            });
          }
        }
      } catch (e) {
        debugPrint('Error cek role: $e');
      }
    }
  }

  Future<void> _simpanSLA(int val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('target_sla', val);
    setState(() => _targetSLA = val);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Target SLA Default diperbarui!')));
  }

  Future<void> _toggleTema(bool val) async {
    // Dark theme is no longer supported. Do nothing.
  }

  Future<void> _backupDataJSON() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menyiapkan backup JSON...')));
    try {
      final snapshot = await FirebaseFirestore.instance.collection('data_notaris').get();
      if (snapshot.docs.isEmpty) return;
      // Sertakan ID dokumen agar dapat direstore dengan benar
      List<Map<String, dynamic>> allData = snapshot.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, ...data};
      }).toList();
      String dataJson = json.encode(allData);
      final direktori = await getTemporaryDirectory();
      final pathFile = '${direktori.path}/Backup_Notaris_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File(pathFile);
      await file.writeAsString(dataJson);
      await Share.shareXFiles([XFile(pathFile)], text: 'Backup JSON');
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _backupDataExcel() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menyiapkan backup Excel...')));
    try {
      final snapshot = await FirebaseFirestore.instance.collection('data_notaris').get();
      if (snapshot.docs.isEmpty) return;
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Data_Notaris'];
      excel.setDefaultSheet('Data_Notaris');
      sheetObject.appendRow(['ID', 'Debitur', 'Notaris', 'KCU', 'PIC Bank'].map((e) => TextCellValue(e)).toList());
      for (var doc in snapshot.docs) {
        var d = doc.data();
        sheetObject.appendRow([d['id'], d['debitur'], d['notaris'], d['kcu'], d['picBank']].map((e) => TextCellValue(e?.toString() ?? '')).toList());
      }
      var fileBytes = excel.save();
      if (fileBytes != null) {
        final direktori = await getTemporaryDirectory();
        final pathFile = '${direktori.path}/Laporan_${DateTime.now().millisecondsSinceEpoch}.xlsx';
        File(pathFile).writeAsBytesSync(fileBytes);
        await Share.shareXFiles([XFile(pathFile)]);
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _restoreDataJSON() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['xlsx'],
);
      if (result != null) {
        File file = File(result.files.single.path!);
        String isiJson = await file.readAsString();
        List<dynamic> dataBaru = json.decode(isiJson);
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Restore Data'),
            content: Text('Upload ${dataBaru.length} data ke Cloud?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('BATAL')),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  WriteBatch batch = FirebaseFirestore.instance.batch();
                  int count = 0;
                  for (var item in dataBaru) {
                    if (item is Map && item.containsKey('id')) {
                      final id = item['id'].toString();
                      batch.set(FirebaseFirestore.instance.collection('data_notaris').doc(id), Map<String, dynamic>.from(item));
                      count++;
                      if (count % 400 == 0) {
                        await batch.commit();
                        batch = FirebaseFirestore.instance.batch();
                      }
                    }
                  }
                  await batch.commit();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil direstore!')));
                },
                child: const Text('RESTORE'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _hapusSemuaData() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Data', style: TextStyle(color: Colors.red)),
        content: const Text('Yakin ingin menghapus semua data di Cloud?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('BATAL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              var snapshot = await FirebaseFirestore.instance.collection('data_notaris').get();
              WriteBatch batch = FirebaseFirestore.instance.batch();
              int count = 0;
              for (var doc in snapshot.docs) {
                batch.delete(doc.reference);
                count++;
                if (count % 400 == 0) {
                  await batch.commit();
                  batch = FirebaseFirestore.instance.batch();
                }
              }
              await batch.commit();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data dibersihkan!')));
            },
            child: const Text('HAPUS'),
          ),
        ],
      ),
    );
  }

  /// Builds a settings list tile used in the Backup & Restore card. It
  /// displays an icon with a coloured accent, the title, and handles
  /// tap callbacks. Use [danger] to emphasise destructive actions.
  Widget _buildSettingTile({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.cardM),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: AppSpacing.base),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: danger ? AppColors.error : AppColors.textPrimary,
                  fontWeight: danger ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the settings screen in a responsive shell. Index 1 corresponds to
    // the Pengaturan menu item in the sidebar/drawer. Selecting the
    // Beranda item (index 0) will pop this screen and return to the
    // dashboard. We do not provide additional actions in the top bar.
    return SiraResponsiveShell(
      title: 'Pengaturan',
      currentIndex: 1,
      onItemSelected: (index) {
        if (index == 0) {
          Navigator.of(context).pop();
        }
      },
      actions: const [],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Target SLA setting
            SiraSolidCard(
              margin: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Target SLA', style: AppTextStyles.headingSmall),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButton<int>(
                    value: _targetSLA,
                    style: AppTextStyles.bodyLarge,
                    borderRadius: BorderRadius.circular(AppRadius.cardM),
                    dropdownColor: AppColors.surfaceL1,
                    items: [14, 30, 45, 60, 90]
                        .map((int val) => DropdownMenuItem<int>(
                              value: val,
                              child: Text('$val Hari', style: AppTextStyles.bodyLarge),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) _simpanSLA(val);
                    },
                  ),
                ],
              ),
            ),

            // Backup & Restore for admin only
            if (userRole == 'ADMIN')
              SiraSolidCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Backup & Restore', style: AppTextStyles.headingSmall),
                    const SizedBox(height: AppSpacing.sm),
                    _buildSettingTile(
                      icon: Icons.table_chart,
                      color: AppColors.success,
                      title: 'Ekspor Excel',
                      onTap: _backupDataExcel,
                    ),
                    const Divider(height: 1, color: AppColors.borderSubtle),
                    _buildSettingTile(
                      icon: Icons.code,
                      color: AppColors.warning,
                      title: 'Backup JSON',
                      onTap: _backupDataJSON,
                    ),
                    const Divider(height: 1, color: AppColors.borderSubtle),
                    _buildSettingTile(
                      icon: Icons.restore,
                      color: AppColors.primary,
                      title: 'Restore JSON',
                      onTap: _restoreDataJSON,
                    ),
                    const Divider(height: 1, color: AppColors.borderSubtle),
                    _buildSettingTile(
                      icon: Icons.delete,
                      color: AppColors.error,
                      title: 'Reset Database',
                      onTap: _hapusSemuaData,
                      danger: true,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}