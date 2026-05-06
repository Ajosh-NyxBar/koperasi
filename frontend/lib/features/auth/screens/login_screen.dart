import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authProvider.notifier).clearError();

    final success = await ref.read(authProvider.notifier).login(
          _emailCtrl.text.trim(),
          _passCtrl.text,
        );

    if (success && mounted) {
      final user = ref.read(authProvider).user;
      context.go(user?.isAdmin == true ? '/admin' : '/member');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.account_balance_rounded, size: 32, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text(
                  'Selamat Datang',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Masuk ke akun koperasi Anda',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 36),
                if (state.error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(state.error!, style: const TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                AppTextField(
                  label: 'Email',
                  hint: 'Masukkan email',
                  controller: _emailCtrl,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) => v == null || v.isEmpty ? 'Email wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Password',
                  hint: 'Masukkan password',
                  controller: _passCtrl,
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) => v == null || v.isEmpty ? 'Password wajib diisi' : null,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text('Lupa Password?'),
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Masuk',
                  onPressed: _login,
                  isLoading: state.isLoading,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun? ',
                      style: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: const Text('Daftar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
