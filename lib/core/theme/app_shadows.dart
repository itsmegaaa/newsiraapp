import 'package:flutter/material.dart';

abstract class AppShadows {
  static const List<BoxShadow> subtle = [
    BoxShadow(color: Color(0x0A1A2340), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x061A2340), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(color: Color(0x141A2340), blurRadius: 24, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x081A2340), blurRadius: 6, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> deep = [
    BoxShadow(color: Color(0x201A2340), blurRadius: 40, offset: Offset(0, 16)),
    BoxShadow(color: Color(0x101A2340), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> primaryGlow = [
    BoxShadow(color: Color(0x503D52FF), blurRadius: 20, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x283D52FF), blurRadius: 6, offset: Offset(0, 2)),
  ];
}
