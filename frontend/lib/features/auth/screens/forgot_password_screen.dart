import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/services/auth_service.dart';
import '../../../core/utils/extensions.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _isLoading = false;
  bool _otpSent = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      await ref.read(authServiceProvider).forgotPassword(_emailCtrl.text.trim());
      setState(() { _otpSent = true; _isLoading = false; });
      if (mounted) context.showSuccessSnack('OTP terkirim ke email Anda');
    } on ApiException catch (e) {
      setState(() { _error = e.firstError; _isLoading = false; });
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpCtrl.text.isEmpty) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final token = await ref.read(authServiceProvider).verifyOtp(
        _emailCtrl.text.trim(),
        _otpCtrl.text.trim(),
      );
      if (mounted) {
        context.push('/reset-password?email=${_emailCtrl.text.trim()}&token=$token');
      }
    } on ApiException catch (e) {
      setState(() { _error = e.firstError; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lupa Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_reset_rounded, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text(
                _otpSent ? 'Masukkan OTP' : 'Reset Password',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                _otpSent
                    ? 'Masukkan kode OTP yang dikirim ke email Anda'
                    : 'Masukkan email untuk menerima kode OTP',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              if (_error != null) ...[
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
                      Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.error))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (!_otpSent) ...[
                AppTextField(
                  label: 'Email',
                  hint: 'Masukkan email terdaftar',
                  controller: _emailCtrl,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || v.isEmpty ? 'Email wajib diisi' : null,
                ),
                const SizedBox(height: 24),
                AppButton(label: 'Kirim OTP', onPressed: _sendOtp, isLoading: _isLoading),
              ] else ...[
                AppTextField(
                  label: 'Kode OTP',
                  hint: 'Masukkan 6 digit OTP',
                  controller: _otpCtrl,
                  prefixIcon: Icons.pin_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                AppButton(label: 'Verifikasi', onPressed: _verifyOtp, isLoading: _isLoading),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: _isLoading ? null : _sendOtp,
                    child: const Text('Kirim ulang OTP'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
