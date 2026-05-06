import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/services/auth_service.dart';
import '../../../core/utils/extensions.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final String token;

  const ResetPasswordScreen({super.key, required this.email, required this.token});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      await ref.read(authServiceProvider).resetPassword(
        widget.token,
        _passCtrl.text,
        _confirmCtrl.text,
      );
      if (mounted) {
        context.showSuccessSnack('Password berhasil direset');
        context.go('/login');
      }
    } on ApiException catch (e) {
      setState(() { _error = e.firstError; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password Baru',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Buat password baru untuk akun ${widget.email}',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.error))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              AppTextField(
                label: 'Password Baru',
                hint: 'Minimal 8 karakter',
                controller: _passCtrl,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: (v) => v != null && v.length < 8 ? 'Minimal 8 karakter' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Konfirmasi Password',
                hint: 'Ulangi password baru',
                controller: _confirmCtrl,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: (v) => v != _passCtrl.text ? 'Password tidak cocok' : null,
              ),
              const SizedBox(height: 24),
              AppButton(label: 'Reset Password', onPressed: _reset, isLoading: _isLoading),
            ],
          ),
        ),
      ),
    );
  }
}
