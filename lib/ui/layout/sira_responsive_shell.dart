import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/user_provider.dart';
import '../../core/theme/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../navigation/sira_page_route.dart';
import '../screens/dashboard/laporan_screen.dart';
import '../screens/dashboard/log_screen.dart';
import '../screens/master/master_bank_screen.dart';
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
    final isMobile = MediaQuery.of(context).size.width < AppBreakpoints.mobile;
    final shellPadding = isMobile
        ? const EdgeInsets.fromLTRB(
            AppSpacing.base,
            AppSpacing.base + kToolbarHeight,
            AppSpacing.base,
            AppSpacing.base,
          )
        : (contentPadding ?? const EdgeInsets.all(AppSpacing.xl));

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
                  onLogoutTap: user.logout,
                ),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxContentWidth ?? double.infinity,
                    ),
                    child: Padding(padding: shellPadding, child: child),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
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
              onLogoutTap: user.logout,
            )
          : null,
      floatingActionButton: floatingActionButton,
      body: body,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: false,
      actions: actions,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.glassFill,
              border: Border(
                bottom: BorderSide(color: AppColors.borderSubtle, width: 0.5),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
    );
  }

  void _openMenu(BuildContext context, SiraMenu menu) {
    if (menu == activeMenu) return;
    final route = switch (menu) {
      SiraMenu.dashboard => const HomeScreen(),
      SiraMenu.laporan => const LaporanScreen(),
      SiraMenu.masterBank => const MasterBankScreen(),
      SiraMenu.log => const LogScreen(),
    };
    Navigator.of(
      context,
    ).pushAndRemoveUntil(SiraPageRoute(child: route), (route) => false);
  }
}
