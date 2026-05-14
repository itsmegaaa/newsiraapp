import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';

enum SiraToastType { success, error, warning, info }

class SiraToast {
  static void show(
    BuildContext context, {
    required SiraToastType type,
    required String message,
  }) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => _ToastOverlay(type: type, message: message),
    );
    overlay.insert(entry);
    Timer(const Duration(seconds: 3), entry.remove);
  }
}

class _ToastOverlay extends StatefulWidget {
  const _ToastOverlay({required this.type, required this.message});

  final SiraToastType type;
  final String message;

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < AppBreakpoints.mobile;
    final semantic = _semanticStyle(widget.type);

    final toast = Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: isMobile ? AppSpacing.base : 0,
            right: AppSpacing.base,
            left: AppSpacing.base,
            bottom: isMobile ? 0 : AppSpacing.base,
          ),
          child: Align(
            alignment: isMobile ? Alignment.topCenter : Alignment.bottomRight,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.surfaceL1,
                  borderRadius: AppRadius.cardMd,
                  border: Border.all(color: AppColors.borderSubtle),
                  boxShadow: AppShadows.medium,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(semantic.icon, color: semantic.color, size: 18),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return IgnorePointer(
      child: FadeTransition(
        opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        child: SlideTransition(
          position:
              Tween<Offset>(
                begin: isMobile
                    ? const Offset(0, -0.08)
                    : const Offset(0.08, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Curves.easeOutCubic,
                ),
              ),
          child: toast,
        ),
      ),
    );
  }

  _ToastSemantic _semanticStyle(SiraToastType type) {
    switch (type) {
      case SiraToastType.success:
        return const _ToastSemantic(AppColors.success, Icons.check_circle);
      case SiraToastType.error:
        return const _ToastSemantic(AppColors.error, Icons.error_outline);
      case SiraToastType.warning:
        return const _ToastSemantic(AppColors.warning, Icons.warning_amber);
      case SiraToastType.info:
        return const _ToastSemantic(AppColors.info, Icons.info_outline);
    }
  }
}

class _ToastSemantic {
  const _ToastSemantic(this.color, this.icon);

  final Color color;
  final IconData icon;
}
