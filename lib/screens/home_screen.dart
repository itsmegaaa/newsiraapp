// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'loading_dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import design system tokens and widgets
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_breakpoints.dart';
import '../ui/layout/sira_page_background.dart';
import '../ui/widgets/sira_solid_card.dart';
import '../ui/navigation/sira_page_route.dart';

/// Halaman pemilihan dashboard bank. Menggunakan desain sistem SIRA dengan
/// latar belakang gradient, kartu padat untuk setiap bank, dan tata letak
/// responsif (satu kolom di mobile, dua kolom di desktop).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Menghasilkan sapaan berdasarkan jam saat ini.
  String _getSapaan() {
    final jam = DateTime.now().hour;
    if (jam >= 3 && jam < 11) {
      return 'Selamat Pagi';
    } else if (jam >= 11 && jam < 15) {
      return 'Selamat Siang';
    } else if (jam >= 15 && jam < 18) {
      return 'Selamat Sore';
    }
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    // Daftar bank. 'tersedia' menentukan apakah pengguna dapat membuka dashboard tersebut.
    final List<Map<String, dynamic>> daftarBank = [
      {
        'nama': 'Bank Mandiri',
        'gambar': 'assets/man.png',
        'gambar_loading': 'assets/mandiri_load.png',
        'tersedia': true,
      },
      {
        'nama': 'Bank BCA',
        'gambar': 'assets/bg_bca.png',
        'tersedia': false,
      },
    ];

    return SiraPageBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: avatar, sapaan, dan tombol keluar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.surfaceL2,
                          child: Icon(Icons.person, color: AppColors.primary, size: 28),
                        ),
                        const SizedBox(width: AppSpacing.base),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getSapaan(),
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Pilih Dashboard Bank',
                              style: AppTextStyles.headingSmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Tombol Logout
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                      tooltip: 'Keluar',
                      onPressed: () async {
                        final bool confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Keluar'),
                                content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('BATAL'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('KELUAR'),
                                  ),
                                ],
                              ),
                            ) ??
                            false;
                        if (confirm) {
                          await FirebaseAuth.instance.signOut();
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Grid daftar bank. Menggunakan Wrap agar responsif terhadap lebar layar.
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Tentukan jumlah kolom berdasarkan breakpoint
                    final double width = constraints.maxWidth;
                    final int columnCount = width < AppBreakpoints.mobile ? 1 : 2;
                    final double itemWidth = (width - (columnCount + 1) * AppSpacing.base) / columnCount;

                    return SingleChildScrollView(
                      child: Wrap(
                        spacing: AppSpacing.base,
                        runSpacing: AppSpacing.base,
                        children: daftarBank.map((bank) {
                          return SizedBox(
                            width: itemWidth,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(AppRadius.cardM),
                              onTap: bank['tersedia']
                                  ? () {
                                      Navigator.of(context).push(
                                        SiraPageRoute(
                                          builder: (context) => LoadingDashboardScreen(
                                            namaBank: bank['nama'],
                                            warnaBank: AppColors.primary,
                                            logoPath: bank['gambar_loading'] ?? bank['gambar'],
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              child: SiraSolidCard(
                                padding: EdgeInsets.zero,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Gambar bank (dengan rasio 16:9)
                                    AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(AppRadius.cardM),
                                        ),
                                        child: Image.asset(
                                          bank['gambar'],
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            color: AppColors.surfaceL2,
                                            alignment: Alignment.center,
                                            child: const Icon(Icons.account_balance, size: 40, color: AppColors.primary),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(AppSpacing.base),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              bank['nama'].toString(),
                                              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          bank['tersedia']
                                              ? const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary)
                                              : Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.borderSubtle,
                                                    borderRadius: BorderRadius.circular(AppRadius.cardS),
                                                  ),
                                                  child: Text(
                                                    'Coming Soon',
                                                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}