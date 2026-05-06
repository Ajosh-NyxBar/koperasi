import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _occupationCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _addressCtrl.dispose();
    _occupationCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authProvider.notifier).clearError();

    final success = await ref.read(authProvider.notifier).register({
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'password': _passCtrl.text,
      'password_confirmation': _confirmCtrl.text,
      'address': _addressCtrl.text.trim(),
      'occupation': _occupationCtrl.text.trim(),
    });

    if (success && mounted) {
      final user = ref.read(authProvider).user;
      context.go(user?.isAdmin == true ? '/admin' : '/member');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Anggota')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buat Akun Baru',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Isi data diri untuk mendaftar',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
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
                      Expanded(child: Text(state.error!, style: const TextStyle(color: AppColors.error))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              AppTextField(
                label: 'Nama Lengkap',
                hint: 'Masukkan nama lengkap',
                controller: _nameCtrl,
                prefixIcon: Icons.person_outline,
                validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Email',
                hint: 'Masukkan email',
                controller: _emailCtrl,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || v.isEmpty ? 'Email wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'No. Telepon',
                hint: 'Masukkan no. telepon',
                controller: _phoneCtrl,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Alamat',
                hint: 'Masukkan alamat',
                controller: _addressCtrl,
                prefixIcon: Icons.location_on_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Pekerjaan',
                hint: 'Masukkan pekerjaan',
                controller: _occupationCtrl,
                prefixIcon: Icons.work_outline,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Password',
                hint: 'Minimal 8 karakter',
                controller: _passCtrl,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: (v) => v != null && v.length < 8 ? 'Minimal 8 karakter' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Konfirmasi Password',
                hint: 'Ulangi password',
                controller: _confirmCtrl,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: (v) => v != _passCtrl.text ? 'Password tidak cocok' : null,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Daftar',
                onPressed: _register,
                isLoading: state.isLoading,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Sudah punya akun? ', style: TextStyle(color: AppColors.onSurfaceVariant)),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Masuk'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
