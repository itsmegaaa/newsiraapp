import 'package:flutter/material.dart';

abstract class AppRadius {
  static const double sm = 6.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double sheet = 16.0;
  static const double button = 8.0;
  static const double pill = 999.0;

  static final BorderRadius cardMd = BorderRadius.circular(md);
  static final BorderRadius cardLg = BorderRadius.circular(lg);
  static final BorderRadius cardXl = BorderRadius.circular(xl);
  static final BorderRadius btnPill = BorderRadius.circular(pill);
  static final BorderRadius inputSm = BorderRadius.circular(sm);
}
