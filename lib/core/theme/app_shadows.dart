import 'package:flutter/material.dart';

abstract class AppShadows {
  static const List<BoxShadow> none = [];

  static const List<BoxShadow> subtle = [
    BoxShadow(color: Color(0x080F0F0F), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(color: Color(0x140F0F0F), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> deep = [
    BoxShadow(color: Color(0x290F0F0F), blurRadius: 48, offset: Offset(0, 16)),
  ];

  static const List<BoxShadow> primaryGlow = subtle;
  static const List<BoxShadow> glassHero = subtle;
  static const List<BoxShadow> glassPanel = subtle;
}
