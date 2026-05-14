import 'package:flutter/material.dart';

// --- Variabel Global untuk Tema Gelap ---
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

// --- Fungsi Helper Format Rupiah ---
String formatRupiah(String angka) {
  if (angka.isEmpty) return '0';
  angka = angka.replaceAll(RegExp(r'[^0-9]'), ''); 
  if (angka.isEmpty) return '0';
  
  String hasil = '';
  int hitung = 0;
  for (int i = angka.length - 1; i >= 0; i--) {
    hasil = angka[i] + hasil;
    hitung++;
    if (hitung == 3 && i > 0) {
      hasil = '.$hasil';
      hitung = 0;
    }
  }
  return hasil;
}