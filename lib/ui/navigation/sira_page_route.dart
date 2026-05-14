import 'package:flutter/material.dart';

/// A custom page route that implements the slide‑from‑bottom
/// animation used throughout the app. When pushing a new screen,
/// the new page slides up from the bottom while the old page
/// remains static. On pop, the reverse happens. This closely
/// resembles iOS sheet transitions and matches the design brief.
class SiraPageRoute<T> extends PageRouteBuilder<T> {
  SiraPageRoute({required WidgetBuilder builder})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );
          },
        );
}