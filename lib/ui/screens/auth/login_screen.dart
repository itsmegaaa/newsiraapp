import 'package:cloud_firestore/cloud_firestore.dart';
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
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isSignUp = false;
  String _errorMessage = '';

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final confirmPassword = _confirmPasswordCtrl.text.trim();

    final validationError = _validateInput(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    if (validationError != null) {
      setState(() {
        _errorMessage = validationError;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_isSignUp) {
        await _register(name: name, email: email, password: password);
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = _mapFirebaseError(e);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan sistem. Coba lagi nanti.';
      });
    }
  }

  Future<void> _register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    await credential.user?.updateDisplayName(name);

    await FirebaseFirestore.instance.collection('users').doc(email).set({
      'nama': name,
      'role': 'STAFF',
      'email': email,
      'uid': credential.user?.uid,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String? _validateInput({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    if (_isSignUp && name.isEmpty) {
      return 'Nama lengkap tidak boleh kosong.';
    }

    if (email.isEmpty || password.isEmpty) {
      return 'Email dan password tidak boleh kosong.';
    }

    if (_isSignUp) {
      if (confirmPassword.isEmpty) {
        return 'Konfirmasi password tidak boleh kosong.';
      }

      if (password.length < 6) {
        return 'Password minimal 6 karakter.';
      }

      if (password != confirmPassword) {
        return 'Konfirmasi password tidak cocok.';
      }
    }

    return null;
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'invalid-email':
        return 'Email tidak ditemukan atau tidak valid.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Kombinasi email dan password salah.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'email-already-in-use':
        return 'Email ini sudah digunakan.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      default:
        return _isSignUp
            ? 'Gagal membuat akun: ${e.message}'
            : 'Gagal masuk: ${e.message}';
    }
  }

  void _toggleAuthMode() {
    if (_isLoading) return;

    setState(() {
      _isSignUp = !_isSignUp;
      _errorMessage = '';
      _passwordCtrl.clear();
      _confirmPasswordCtrl.clear();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: SiraPageBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? AppSpacing.base : AppSpacing.xl,
                    vertical: isMobile ? AppSpacing.base : AppSpacing.xl,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - (isMobile ? 32 : 48),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: SiraGlassCard(
                          borderRadius: AppRadius.cardXl,
                          padding: EdgeInsets.all(
                            isMobile ? AppSpacing.xl : AppSpacing.xxxl,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const _BrandHeader(),
                              const SizedBox(height: AppSpacing.xxl),
                              Text(
                                _isSignUp ? 'Daftar' : 'Masuk',
                                style: Theme.of(context).textTheme.displaySmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                _isSignUp
                                    ? 'Buat akun untuk menggunakan SIRA.'
                                    : 'Masuk untuk melanjutkan ke akun SIRA.',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                              if (_isSignUp) ...[
                                TextField(
                                  controller: _nameCtrl,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    labelText: 'Nama',
                                    hintText: 'Nama lengkap',
                                    prefixIcon: Icon(Icons.badge_outlined),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.base),
                              ],
                              TextField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'nama@email.com',
                                  prefixIcon: Icon(
                                    Icons.alternate_email_rounded,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.base),
                              TextField(
                                controller: _passwordCtrl,
                                obscureText: !_isPasswordVisible,
                                textInputAction: _isSignUp
                                    ? TextInputAction.next
                                    : TextInputAction.done,
                                onSubmitted: (_) {
                                  if (!_isSignUp) {
                                    _submit();
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: _isSignUp
                                      ? 'Buat password'
                                      : 'Masukkan password',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
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
                              if (_isSignUp) ...[
                                const SizedBox(height: AppSpacing.base),
                                TextField(
                                  controller: _confirmPasswordCtrl,
                                  obscureText: !_isConfirmPasswordVisible,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _submit(),
                                  decoration: InputDecoration(
                                    labelText: 'Konfirmasi Password',
                                    hintText: 'Ulangi password',
                                    prefixIcon: const Icon(
                                      Icons.lock_reset_outlined,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _isConfirmPasswordVisible =
                                              !_isConfirmPasswordVisible;
                                        });
                                      },
                                      icon: Icon(
                                        _isConfirmPasswordVisible
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              if (_errorMessage.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.base),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: AppColors.errorSoft.withValues(
                                      alpha: 0.9,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.sm,
                                    ),
                                    border: Border.all(
                                      color: AppColors.error.withValues(
                                        alpha: 0.18,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    _errorMessage,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.error,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: AppSpacing.xxl),
                              SiraPrimaryButton(
                                label: _isSignUp ? 'Daftar' : 'Masuk',
                                onPressed: _submit,
                                isLoading: _isLoading,
                                expanded: true,
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              Center(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      _isSignUp
                                          ? 'Sudah punya akun? '
                                          : 'Belum punya akun? ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                    TextButton(
                                      onPressed: _toggleAuthMode,
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 32),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        _isSignUp ? 'Masuk' : 'Daftar',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: AppColors.primarySoft,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.16),
            ),
          ),
          child: const Icon(
            Icons.description_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSpacing.base),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SIRA',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Sistem Informasi Rekap Akta',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
