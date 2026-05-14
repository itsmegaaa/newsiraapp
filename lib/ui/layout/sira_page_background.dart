import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Wraps a page in a simple gradient background. The design
/// specification calls for a mesh gradient behind the content. For
/// simplicity in this implementation, a diagonal linear gradient is
/// used. This widget should be placed as high in the tree as
/// possible to avoid redundant gradients.
class SiraPageBackground extends StatelessWidget {
  final Widget child;

  const SiraPageBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.background,
            AppColors.surfaceL2,
          ],
        ),
      ),
      child: child,
    );
  }
}