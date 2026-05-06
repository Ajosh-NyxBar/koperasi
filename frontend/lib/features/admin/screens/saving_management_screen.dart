import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/services/saving_service.dart';
import '../../../data/services/member_service.dart';
import '../../../data/models/member_model.dart';

class AdminSavingManagementScreen extends ConsumerStatefulWidget {
  const AdminSavingManagementScreen({super.key});

  @override
  ConsumerState<AdminSavingManagementScreen> createState() => _AdminSavingManagementScreenState();
}

class _AdminSavingManagementScreenState extends ConsumerState<AdminSavingManagementScreen> {
  List<MemberModel> _members = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final result = await ref.read(memberServiceProvider).getMembers();
      setState(() { _members = result.items; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _showAction(MemberModel member, String action) {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${action == 'deposit' ? 'Setor' : action == 'withdraw' ? 'Tarik' : 'Bayar Wajib'} - ${member.name}',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            AppTextField(label: 'Jumlah (Rp)', controller: amountCtrl, keyboardType: TextInputType.number, prefixIcon: Icons.attach_money),
            const SizedBox(height: 12),
            AppTextField(label: 'Catatan', controller: noteCtrl, maxLines: 2),
            const SizedBox(height: 20),
            AppButton(
              label: 'Proses',
              onPressed: () async {
                try {
                  final svc = ref.read(savingServiceProvider);
                  final data = {'member_id': member.id, 'amount': double.tryParse(amountCtrl.text) ?? 0, 'note': noteCtrl.text};
                  if (action == 'deposit') await svc.deposit(data);
                  else if (action == 'withdraw') await svc.withdraw(data);
                  else await svc.payMandatory(data);
                  if (mounted) { Navigator.pop(ctx); context.showSuccessSnack('Transaksi berhasil'); _load(); }
                } on ApiException catch (e) {
                  if (mounted) context.showSnack(e.firstError, isError: true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Tabungan')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _members.isEmpty
                  ? const Center(child: Text('Tidak ada anggota'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _members.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final m = _members[i];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                  child: Text(m.name.isNotEmpty ? m.name[0].toUpperCase() : '?', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text(m.memberId, style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                                ])),
                                if (m.savingBalance != null) Text(m.savingBalance!.currency, style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                              ]),
                              const SizedBox(height: 10),
                              Row(children: [
                                Expanded(child: _ActionBtn(label: 'Setor', icon: Icons.arrow_downward, color: AppColors.success, onTap: () => _showAction(m, 'deposit'))),
                                const SizedBox(width: 8),
                                Expanded(child: _ActionBtn(label: 'Tarik', icon: Icons.arrow_upward, color: AppColors.error, onTap: () => _showAction(m, 'withdraw'))),
                                const SizedBox(width: 8),
                                Expanded(child: _ActionBtn(label: 'Wajib', icon: Icons.calendar_month, color: AppColors.info, onTap: () => _showAction(m, 'mandatory'))),
                              ]),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
