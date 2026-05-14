import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';

/// Simple sidebar for desktop layouts. Displays a vertical list of
/// navigation items and a logout button. When [onItemSelected] is
/// provided, tapping on a menu item will invoke it with the index of
/// the selected item.
class SiraSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onItemSelected;

  const SiraSidebar({super.key, required this.selectedIndex, this.onItemSelected});

  // Define your menu items here. Extend or modify this list to
  // accommodate additional screens. The order matters; keep it in
  // sync with your page routing.
  final List<_SidebarItemData> _items = const [
    _SidebarItemData(icon: Icons.home_outlined, label: 'Beranda'),
    _SidebarItemData(icon: Icons.settings_outlined, label: 'Pengaturan'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: AppColors.surfaceL1,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          // Header with app name or logo
          Text('SIRA', style: AppTextStyles.headingMedium),
          const SizedBox(height: AppSpacing.xl),
          // Menu items
          for (var i = 0; i < _items.length; i++)
            _SidebarItem(
              icon: _items[i].icon,
              label: _items[i].label,
              selected: i == selectedIndex,
              onTap: () => onItemSelected?.call(i),
            ),
          const Spacer(),
          const Divider(height: 1),
          // Logout
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.cardS),
            onTap: () {
              // TODO: Integrate with authentication provider
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
              child: Row(
                children: [
                  const Icon(Icons.exit_to_app, color: AppColors.error),
                  const SizedBox(width: AppSpacing.md),
                  Text('Keluar', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Private data class representing a sidebar item. Keeps the API of
/// [SiraSidebar] clean.
class _SidebarItemData {
  final IconData icon;
  final String label;
  const _SidebarItemData({required this.icon, required this.label});
}

/// Represents a single interactive row within the sidebar.
class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = selected ? AppColors.primarySoft : AppColors.surfaceL1;
    final fgColor = selected ? AppColors.primary : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.cardS),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.cardS),
        ),
        child: Row(
          children: [
            Icon(icon, color: fgColor),
            const SizedBox(width: AppSpacing.md),
            Text(label, style: AppTextStyles.bodyLarge.copyWith(color: fgColor)),
          ],
        ),
      ),
    );
  }
}