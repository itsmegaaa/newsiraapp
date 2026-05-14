// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import 'sira_sidebar.dart';
import 'sira_mobile_drawer.dart';
import 'sira_page_background.dart';

/// A wrapper that provides responsive navigation. On mobile widths
/// (< [AppBreakpoints.mobile]), it displays an AppBar with a
/// hamburger icon and a [Drawer]. On wider screens it shows a
/// fixed [SiraSidebar] on the left. The [child] is the main body
/// content. Use this class as the top‑level widget in your screens
/// instead of [Scaffold].
class SiraResponsiveShell extends StatefulWidget {
  final Widget child;
  final String title;
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final List<Widget>? actions;

  const SiraResponsiveShell({
    super.key,
    required this.child,
    required this.title,
    required this.currentIndex,
    required this.onItemSelected,
    this.actions,
  });

  @override
  State<SiraResponsiveShell> createState() => _SiraResponsiveShellState();
}

class _SiraResponsiveShellState extends State<SiraResponsiveShell> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < AppBreakpoints.mobile;
        if (isMobile) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.cardL),
                  bottomRight: Radius.circular(AppRadius.cardL),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: AppBar(
                    backgroundColor: AppColors.glassBackground,
                    elevation: 0,
                    centerTitle: true,
                    title: Text(widget.title, style: AppTextStyles.headingMedium),
                    actions: widget.actions,
                    leading: Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, color: AppColors.textPrimary),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            drawer: SiraMobileDrawer(
              selectedIndex: widget.currentIndex,
              onItemSelected: widget.onItemSelected,
            ),
            body: SiraPageBackground(
              child: SafeArea(
                child: widget.child,
              ),
            ),
          );
        } else {
          return Scaffold(
            body: Row(
              children: [
                SiraSidebar(
                  selectedIndex: widget.currentIndex,
                  onItemSelected: widget.onItemSelected,
                ),
                Expanded(
                  child: SiraPageBackground(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Custom top bar
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(AppRadius.cardL),
                            bottomRight: Radius.circular(AppRadius.cardL),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: AppColors.glassBackground,
                                border: Border(
                                  bottom: BorderSide(color: AppColors.borderSubtle.withOpacity(0.5)),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(widget.title, style: AppTextStyles.headingMedium),
                                  const Spacer(),
                                  ...(widget.actions ?? <Widget>[]),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: widget.child,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}