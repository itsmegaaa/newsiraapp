import 'package:flutter/material.dart';
import 'beranda_screen.dart';
// Import design system tokens
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_spacing.dart';
import '../ui/layout/sira_page_background.dart';
import '../ui/navigation/sira_page_route.dart';

class LoadingDashboardScreen extends StatefulWidget {
  final String namaBank;
  final Color warnaBank;
  final String? logoPath;

  const LoadingDashboardScreen({
    super.key, 
    required this.namaBank, 
    required this.warnaBank,
    this.logoPath,
  });

  @override
  State<LoadingDashboardScreen> createState() => _LoadingDashboardScreenState();
}

class _LoadingDashboardScreenState extends State<LoadingDashboardScreen> {
  @override
  void initState() {
    super.initState();
    
    // Memberikan jeda buatan selama 1.5 detik agar animasi terlihat
    Future.delayed(const Duration(milliseconds: 1500), () {
      // pushReplacement memastikan saat user klik 'Back' di Beranda, 
      // mereka kembali ke Home Screen, bukan ke layar loading ini lagi.
      if (mounted) {
        Navigator.pushReplacement(
          context,
          // Gunakan animasi custom dari design system
          SiraPageRoute(builder: (context) => const BerandaNotaris()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use a gradient background and design system styles for the loading screen
    return SiraPageBackground(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              height: 100,
              margin: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: widget.logoPath != null && widget.logoPath!.isNotEmpty
                  ? Image.asset(
                      widget.logoPath!,
                      fit: BoxFit.contain,
                    )
                  : Icon(
                      Icons.account_balance,
                      size: 80,
                      color: widget.warnaBank,
                    ),
            ),
            // Title
            Text(
              'Membuka ${widget.namaBank}',
              style: AppTextStyles.headingSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Menyiapkan ruang kerja...',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                backgroundColor: AppColors.surfaceL2,
                valueColor: AlwaysStoppedAnimation<Color>(widget.warnaBank),
                minHeight: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}