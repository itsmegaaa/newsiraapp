import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import 'sira_sidebar.dart';

class SiraMobileDrawer extends StatelessWidget {
  const SiraMobileDrawer({
    super.key,
    required this.activeMenu,
    required this.userName,
    required this.userRole,
    required this.isAdmin,
    required this.onMenuTap,
    required this.onLogoutTap,
  });

  final SiraMenu activeMenu;
  final String userName;
  final String userRole;
  final bool isAdmin;
  final ValueChanged<SiraMenu> onMenuTap;
  final VoidCallback onLogoutTap;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,
      backgroundColor: AppColors.surfaceL1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: AppRadius.cardLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SIRA',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 22,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      userName.isEmpty ? 'Pengguna' : userName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      userRole,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _DrawerItem(
                icon: Icons.dashboard_outlined,
                label: 'Dashboard',
                isActive: activeMenu == SiraMenu.dashboard,
                onTap: () => onMenuTap(SiraMenu.dashboard),
              ),
              _DrawerItem(
                icon: Icons.folder_open_outlined,
                label: 'Laporan',
                isActive: activeMenu == SiraMenu.laporan,
                onTap: () => onMenuTap(SiraMenu.laporan),
              ),
              if (isAdmin)
                _DrawerItem(
                  icon: Icons.account_balance_outlined,
                  label: 'Master Bank',
                  isActive: activeMenu == SiraMenu.masterBank,
                  onTap: () => onMenuTap(SiraMenu.masterBank),
                ),
              if (isAdmin)
                _DrawerItem(
                  icon: Icons.history_outlined,
                  label: 'Log Aktivitas',
                  isActive: activeMenu == SiraMenu.log,
                  onTap: () => onMenuTap(SiraMenu.log),
                ),
              const Spacer(),
              TextButton.icon(
                onPressed: onLogoutTap,
                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                label: Text(
                  'Keluar aplikasi',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primarySoft : Colors.transparent,
        borderRadius: AppRadius.cardMd,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardMd),
        leading: Icon(
          icon,
          color: isActive ? AppColors.primary : AppColors.textSecondary,
        ),
        title: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isActive ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
