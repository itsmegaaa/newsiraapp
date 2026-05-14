import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';

/// A drawer for mobile layouts. Displays navigation items identical to
/// the desktop sidebar. When an item is selected the drawer will
/// automatically close and invoke [onItemSelected].
class SiraMobileDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onItemSelected;

  const SiraMobileDrawer({super.key, required this.selectedIndex, this.onItemSelected});

  final List<_DrawerItemData> _items = const [
    _DrawerItemData(icon: Icons.home_outlined, label: 'Beranda'),
    _DrawerItemData(icon: Icons.settings_outlined, label: 'Pengaturan'),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Container(
          color: AppColors.surfaceL1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: Text('SIRA', style: AppTextStyles.headingMedium),
              ),
              const SizedBox(height: AppSpacing.xl),
              for (var i = 0; i < _items.length; i++)
                ListTile(
                  leading: Icon(
                    _items[i].icon,
                    color: i == selectedIndex ? AppColors.primary : AppColors.textSecondary,
                  ),
                  title: Text(
                    _items[i].label,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: i == selectedIndex ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                  selected: i == selectedIndex,
                  selectedTileColor: AppColors.primarySoft,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.cardS)),
                  onTap: () {
                    Navigator.of(context).pop();
                    onItemSelected?.call(i);
                  },
                ),
              const Spacer(),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: AppColors.error),
                title: Text('Keluar', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error)),
                onTap: () {
                  // TODO: Integrate with authentication provider
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItemData {
  final IconData icon;
  final String label;
  const _DrawerItemData({required this.icon, required this.label});
}