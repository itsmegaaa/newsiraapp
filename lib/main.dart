import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'controllers/form_laporan_controller.dart';
import 'data/repositories/laporan_repository.dart';
import 'controllers/user_provider.dart';
import 'controllers/laporan_controller.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/portal/home_screen.dart';
import 'controllers/theme_controller.dart';
import 'core/theme/app_theme.dart';

// ============================================================================
// MAIN FUNCTION
// ============================================================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: 40 * 1024 * 1024,
  );

  final themeCtrl = ThemeController();
  await themeCtrl.muatDariPrefs();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeController>.value(value: themeCtrl),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        Provider(create: (_) => LaporanRepository()),
        ChangeNotifierProvider(
          create: (ctx) =>
              LaporanController(repo: ctx.read<LaporanRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              FormLaporanController(repo: context.read<LaporanRepository>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// ============================================================================
// APP ROOT WIDGET
// ============================================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIRA',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: siraLightTheme,
      home: const AuthGate(),
    );
  }
}

// ============================================================================
// AUTH GATE
// ============================================================================
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
