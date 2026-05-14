import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../widgets/sira_glass_card.dart';
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
      width: 264,
      backgroundColor: AppColors.surface,
      shadowColor: Colors.black12,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.base,
            AppSpacing.base,
            AppSpacing.base,
            AppSpacing.lg,
          ),
          child: SiraGlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            borderRadius: AppRadius.cardXl,
            tone: SiraGlassTone.panel,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SiraGlassCard(
                  tone: SiraGlassTone.metric,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.base,
                  ),
                  borderRadius: AppRadius.cardLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SIRA',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
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
                const SizedBox(height: AppSpacing.lg),
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
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'Admin Panel',
                    isActive: activeMenu == SiraMenu.adminPanel,
                    onTap: () => onMenuTap(SiraMenu.adminPanel),
                  ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onLogoutTap,
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                  ),
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
        border: Border.all(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.18)
              : Colors.transparent,
        ),
      ),
      child: ListTile(
        dense: true,
        visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardMd),
        leading: Icon(
          icon,
          size: 20,
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
