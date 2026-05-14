import 'package:flutter/material.dart';

class SiraPageRoute<T> extends PageRouteBuilder<T> {
  SiraPageRoute({required Widget child})
    : super(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, _, _) => child,
        transitionsBuilder: (_, animation, _, child) {
          final slide =
              Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          );
          return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child),
          );
        },
      );
}
