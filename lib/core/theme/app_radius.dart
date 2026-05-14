import 'package:flutter/material.dart';

abstract class AppRadius {
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double sheet = 28.0;
  static const double button = 16.0;
  static const double pill = 999.0;

  static final BorderRadius cardMd = BorderRadius.circular(md);
  static final BorderRadius cardLg = BorderRadius.circular(lg);
  static final BorderRadius cardXl = BorderRadius.circular(xl);
  static final BorderRadius btnPill = BorderRadius.circular(pill);
  static final BorderRadius inputSm = BorderRadius.circular(sm);
}
