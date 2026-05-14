import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/user_provider.dart';
import '../../core/theme/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../navigation/sira_page_route.dart';
import '../screens/admin/admin_panel_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/laporan_screen.dart';
import '../screens/portal/home_screen.dart';
import '../widgets/sira_page_background.dart';
import 'sira_mobile_drawer.dart';
import 'sira_sidebar.dart';

export 'sira_sidebar.dart' show SiraMenu;

class SiraResponsiveShell extends StatelessWidget {
  const SiraResponsiveShell({
    super.key,
    required this.title,
    required this.activeMenu,
    required this.child,
    this.actions = const [],
    this.floatingActionButton,
    this.maxContentWidth,
    this.contentPadding,
  });

  final String title;
  final SiraMenu activeMenu;
  final Widget child;
  final List<Widget> actions;
  final Widget? floatingActionButton;
  final double? maxContentWidth;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < AppBreakpoints.mobile;
    final contentChild = isMobile
        ? MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: child,
          )
        : child;
    final shellPadding = isMobile
        ? const EdgeInsets.fromLTRB(
            AppSpacing.base,
            AppSpacing.base,
            AppSpacing.base,
            AppSpacing.base,
          )
        : (contentPadding ??
              const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
              ));

    final body = Stack(
      children: [
        const Positioned.fill(child: SiraPageBackground()),
        SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isMobile)
                SiraSidebar(
                  activeMenu: activeMenu,
                  userName: user.nama,
                  userRole: user.role,
                  isAdmin: user.isAdmin,
                  onMenuTap: (menu) => _openMenu(context, menu),
                  onLogoutTap: () => _handleLogout(context),
                ),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxContentWidth ?? double.infinity,
                    ),
                    child: Padding(
                      padding: shellPadding,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        child: contentChild,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      extendBodyBehindAppBar: false,
      appBar: isMobile ? _buildAppBar(context) : null,
      drawer: isMobile
          ? SiraMobileDrawer(
              activeMenu: activeMenu,
              userName: user.nama,
              userRole: user.role,
              isAdmin: user.isAdmin,
              onMenuTap: (menu) {
                Navigator.of(context).pop();
                _openMenu(context, menu);
              },
              onLogoutTap: () => _handleLogout(context),
            )
          : null,
      floatingActionButton: floatingActionButton,
      body: body,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return AppBar(
      title: Text(title),
      centerTitle: false,
      actions: actions,
      toolbarHeight: width < AppBreakpoints.mobile ? 64 : kToolbarHeight,
      flexibleSpace: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(AppRadius.lg),
          ),
          border: const Border(bottom: BorderSide(color: AppColors.hairline)),
        ),
      ),
      backgroundColor: AppColors.surfaceCard,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
    );
  }

  void _openMenu(BuildContext context, SiraMenu menu) {
    if (menu == activeMenu) return;
    final user = context.read<UserProvider>();
    final route = switch (menu) {
      SiraMenu.dashboard => const HomeScreen(),
      SiraMenu.laporan => const LaporanScreen(),
      SiraMenu.adminPanel =>
        user.isAdmin ? const AdminPanelScreen() : const HomeScreen(),
      SiraMenu.masterBank =>
        user.isAdmin ? const AdminPanelScreen() : const HomeScreen(),
      SiraMenu.log => user.isAdmin ? const AdminPanelScreen() : const HomeScreen(),
    };
    Navigator.of(
      context,
    ).pushAndRemoveUntil(SiraPageRoute(child: route), (route) => false);
  }

  Future<void> _handleLogout(BuildContext context) async {
    final navigator = Navigator.of(context);
    final scaffold = Scaffold.maybeOf(context);
    final user = context.read<UserProvider>();

    if (scaffold?.isDrawerOpen ?? false) {
      navigator.pop();
    }

    await user.logout();
    if (!context.mounted) return;

    navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
