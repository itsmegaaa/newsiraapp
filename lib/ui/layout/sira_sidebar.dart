import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../widgets/sira_glass_card.dart';

enum SiraMenu { dashboard, laporan, adminPanel, masterBank, log }

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
      ),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          borderRadius: AppRadius.cardXl,
          border: Border.all(color: AppColors.hairline),
          color: AppColors.surfaceSoft,
        ),
        child: SafeArea(
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
                        'Projects dashboard',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
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
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'Admin Panel',
                    isActive: activeMenu == SiraMenu.adminPanel,
                    onTap: () => onMenuTap(SiraMenu.adminPanel),
                  ),
                ],
                const Spacer(),
                SiraGlassCard(
                  tone: SiraGlassTone.metric,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  borderRadius: AppRadius.cardMd,
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
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
                const SizedBox(height: AppSpacing.xs),
                TextButton.icon(
                  onPressed: onLogoutTap,
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                  ),
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
        ? AppColors.surface
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
          border: Border.all(
            color: widget.isActive
                ? AppColors.primary.withValues(alpha: 0.18)
                : Colors.transparent,
          ),
        ),
        child: ListTile(
          dense: true,
          visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.cardMd),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          leading: Icon(widget.icon, color: foreground, size: 20),
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
