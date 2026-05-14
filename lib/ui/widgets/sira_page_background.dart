import 'package:flutter/material.dart';

class SiraPageBackground extends StatelessWidget {
  const SiraPageBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0F2FF), Color(0xFFF2F4F8), Color(0xFFF5F3FF)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
