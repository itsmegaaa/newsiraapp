import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'utils/globals.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'utils/notifikasi_service.dart';

// Import the design system theme
import 'core/theme/app_theme.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true, 
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  // Inisialisasi layanan notifikasi lokal setelah Firebase siap
  await NotifikasiService.inisialisasi();

  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('tema_gelap') ?? false;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The design brief specifies that only light mode is supported.
    // We therefore ignore the persisted theme preference and always
    // use the light theme defined in AppTheme. This keeps the UI
    // consistent and avoids dark mode bugs.
    return MaterialApp(
      title: 'Laporan Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

// === PENJAGA PINTU LOGIN ===
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Memantau apakah user sedang login atau logout
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Jika ada data user (berarti sudah login), arahkan ke Beranda
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Jika tidak ada user (belum login/logout), arahkan ke Login
        return const LoginScreen();
      },
    );
  }
}