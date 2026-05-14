import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../widgets/sira_glass_card.dart';
import '../../widgets/sira_page_background.dart';
import '../../widgets/sira_primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String _errorMessage = '';

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Email dan password tidak boleh kosong.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        switch (e.code) {
          case 'user-not-found':
          case 'invalid-email':
            _errorMessage = 'Email tidak ditemukan atau tidak valid.';
            break;
          case 'wrong-password':
          case 'invalid-credential':
            _errorMessage = 'Kombinasi email dan password salah.';
            break;
          case 'user-disabled':
            _errorMessage = 'Akun ini telah dinonaktifkan.';
            break;
          case 'too-many-requests':
            _errorMessage = 'Terlalu banyak percobaan. Coba lagi nanti.';
            break;
          default:
            _errorMessage = 'Gagal masuk: ${e.message}';
        }
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan sistem. Coba lagi nanti.';
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: SiraPageBackground()),
          Positioned(
            top: -48,
            right: -24,
            child: _TintBlob(size: 220, color: AppColors.primarySoft),
          ),
          Positioned(
            bottom: -64,
            left: -40,
            child: _TintBlob(size: 260, color: AppColors.surfaceL1),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: SiraGlassCard(
                  borderRadius: AppRadius.cardXl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Masuk ke SIRA',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Sistem Informasi Riwayat Administrasi untuk monitoring berkas dan progres proyek.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'nama@perusahaan.com',
                          prefixIcon: Icon(Icons.alternate_email_rounded),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.base),
                      TextField(
                        controller: _passwordCtrl,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Masukkan password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                      ),
                      if (_errorMessage.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.base),
                        Text(
                          _errorMessage,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xxl),
                      SiraPrimaryButton(
                        label: 'Masuk ke sistem',
                        onPressed: _login,
                        isLoading: _isLoading,
                        expanded: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TintBlob extends StatelessWidget {
  const _TintBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.7),
      ),
    );
  }
}
