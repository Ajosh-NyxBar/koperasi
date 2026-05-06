import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/services/financing_service.dart';

class FinancingApplyScreen extends ConsumerStatefulWidget {
  const FinancingApplyScreen({super.key});

  @override
  ConsumerState<FinancingApplyScreen> createState() => _FinancingApplyScreenState();
}

class _FinancingApplyScreenState extends ConsumerState<FinancingApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _tenorCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();
  final _guaranteeDetailCtrl = TextEditingController();
  String _type = 'murabahah';
  String _guaranteeType = 'sertifikat';
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _tenorCtrl.dispose();
    _purposeCtrl.dispose();
    _guaranteeDetailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(financingServiceProvider).apply({
        'type': _type,
        'amount': double.tryParse(_amountCtrl.text) ?? 0,
        'tenor': int.tryParse(_tenorCtrl.text) ?? 0,
        'purpose': _purposeCtrl.text,
        'guarantee_type': _guaranteeType,
        'guarantee_detail': _guaranteeDetailCtrl.text,
      });
      if (mounted) {
        context.showSuccessSnack('Pengajuan pembiayaan berhasil dikirim');
        context.pop();
      }
    } on ApiException catch (e) {
      setState(() { _error = e.firstError; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajukan Pembiayaan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.error))),
                  ]),
                ),
                const SizedBox(height: 16),
              ],
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Jenis Pembiayaan'),
                items: const [
                  DropdownMenuItem(value: 'murabahah', child: Text('Murabahah')),
                  DropdownMenuItem(value: 'mudharabah', child: Text('Mudharabah')),
                  DropdownMenuItem(value: 'musyarakah', child: Text('Musyarakah')),
                ],
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 16),
              AppTextField(label: 'Jumlah', hint: 'Masukkan jumlah pembiayaan', controller: _amountCtrl, prefixIcon: Icons.attach_money, keyboardType: TextInputType.number, validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null),
              const SizedBox(height: 16),
              AppTextField(label: 'Tenor (bulan)', hint: 'Masukkan tenor', controller: _tenorCtrl, prefixIcon: Icons.calendar_month, keyboardType: TextInputType.number, validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null),
              const SizedBox(height: 16),
              AppTextField(label: 'Tujuan', hint: 'Jelaskan tujuan pembiayaan', controller: _purposeCtrl, prefixIcon: Icons.description, maxLines: 3, validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _guaranteeType,
                decoration: const InputDecoration(labelText: 'Jenis Jaminan'),
                items: const [
                  DropdownMenuItem(value: 'sertifikat', child: Text('Sertifikat')),
                  DropdownMenuItem(value: 'bpkb', child: Text('BPKB')),
                  DropdownMenuItem(value: 'tabungan', child: Text('Tabungan')),
                  DropdownMenuItem(value: 'lainnya', child: Text('Lainnya')),
                ],
                onChanged: (v) => setState(() => _guaranteeType = v!),
              ),
              const SizedBox(height: 16),
              AppTextField(label: 'Detail Jaminan', hint: 'Jelaskan detail jaminan', controller: _guaranteeDetailCtrl, maxLines: 2),
              const SizedBox(height: 24),
              AppButton(label: 'Ajukan Pembiayaan', onPressed: _submit, isLoading: _loading, icon: Icons.send_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
