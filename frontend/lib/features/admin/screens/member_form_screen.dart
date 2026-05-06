import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/services/member_service.dart';

class MemberFormScreen extends ConsumerStatefulWidget {
  final int? memberId;
  const MemberFormScreen({super.key, this.memberId});

  @override
  ConsumerState<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends ConsumerState<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _occupationCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.memberId != null;
    if (_isEdit) _loadMember();
  }

  Future<void> _loadMember() async {
    setState(() => _loading = true);
    try {
      final m = await ref.read(memberServiceProvider).getMember(widget.memberId!);
      _nameCtrl.text = m.name;
      _emailCtrl.text = m.email;
      _phoneCtrl.text = m.phone ?? '';
      _addressCtrl.text = m.address ?? '';
      _occupationCtrl.text = m.occupation ?? '';
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final svc = ref.read(memberServiceProvider);
      final data = {
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'occupation': _occupationCtrl.text.trim(),
        if (!_isEdit && _passCtrl.text.isNotEmpty) 'password': _passCtrl.text,
      };
      if (_isEdit) {
        await svc.updateMember(widget.memberId!, data);
      } else {
        await svc.createMember(data);
      }
      if (mounted) {
        context.showSuccessSnack(_isEdit ? 'Anggota diperbarui' : 'Anggota ditambahkan');
        context.pop();
      }
    } on ApiException catch (e) {
      if (mounted) context.showSnack(e.firstError, isError: true);
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _occupationCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Anggota' : 'Tambah Anggota')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(label: 'Nama', controller: _nameCtrl, prefixIcon: Icons.person_outline, validator: (v) => v == null || v.isEmpty ? 'Wajib' : null),
              const SizedBox(height: 14),
              AppTextField(label: 'Email', controller: _emailCtrl, prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) => v == null || v.isEmpty ? 'Wajib' : null),
              const SizedBox(height: 14),
              AppTextField(label: 'Telepon', controller: _phoneCtrl, prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 14),
              AppTextField(label: 'Alamat', controller: _addressCtrl, prefixIcon: Icons.location_on_outlined, maxLines: 2),
              const SizedBox(height: 14),
              AppTextField(label: 'Pekerjaan', controller: _occupationCtrl, prefixIcon: Icons.work_outline),
              if (!_isEdit) ...[
                const SizedBox(height: 14),
                AppTextField(label: 'Password', controller: _passCtrl, prefixIcon: Icons.lock_outline, obscureText: true, validator: (v) => !_isEdit && (v == null || v.length < 8) ? 'Min 8 karakter' : null),
              ],
              const SizedBox(height: 24),
              AppButton(label: _isEdit ? 'Simpan Perubahan' : 'Tambah Anggota', onPressed: _submit, isLoading: _loading),
            ],
          ),
        ),
      ),
    );
  }
}
