import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

enum SiraMenu { dashboard, laporan, masterBank, log }

class SiraSidebar extends StatelessWidget {
  const SiraSidebar({
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
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: AppColors.surfaceL1,
        border: Border(right: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
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
                      'Projects dashboard',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _SidebarItem(
                icon: Icons.dashboard_outlined,
                label: 'Dashboard',
                isActive: activeMenu == SiraMenu.dashboard,
                onTap: () => onMenuTap(SiraMenu.dashboard),
              ),
              const SizedBox(height: AppSpacing.sm),
              _SidebarItem(
                icon: Icons.folder_open_outlined,
                label: 'Laporan',
                isActive: activeMenu == SiraMenu.laporan,
                onTap: () => onMenuTap(SiraMenu.laporan),
              ),
              if (isAdmin) ...[
                const SizedBox(height: AppSpacing.sm),
                _SidebarItem(
                  icon: Icons.account_balance_outlined,
                  label: 'Master Bank',
                  isActive: activeMenu == SiraMenu.masterBank,
                  onTap: () => onMenuTap(SiraMenu.masterBank),
                ),
                const SizedBox(height: AppSpacing.sm),
                _SidebarItem(
                  icon: Icons.history_outlined,
                  label: 'Log Aktivitas',
                  isActive: activeMenu == SiraMenu.log,
                  onTap: () => onMenuTap(SiraMenu.log),
                ),
              ],
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.surfaceL2,
                  borderRadius: AppRadius.cardMd,
                  border: Border.all(color: AppColors.borderSubtle),
                ),
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
                        Icons.person_outline,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName.isEmpty ? 'Pengguna' : userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            userRole,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                onPressed: onLogoutTap,
                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                label: Text(
                  'Keluar',
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

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
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
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final background = widget.isActive
        ? AppColors.primarySoft
        : _hovered
        ? AppColors.surfaceL3
        : Colors.transparent;
    final foreground = widget.isActive
        ? AppColors.primary
        : AppColors.textSecondary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.cardMd,
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.cardMd),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.sm,
          ),
          leading: Icon(widget.icon, color: foreground),
          title: Text(
            widget.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: foreground,
              fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          onTap: widget.onTap,
        ),
      ),
    );
  }
}
