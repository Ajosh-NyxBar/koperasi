import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/services/financing_service.dart';
import '../../../providers/financing_provider.dart';

class FinancingManagementScreen extends ConsumerStatefulWidget {
  const FinancingManagementScreen({super.key});

  @override
  ConsumerState<FinancingManagementScreen> createState() => _FinancingManagementScreenState();
}

class _FinancingManagementScreenState extends ConsumerState<FinancingManagementScreen> {
  String? _filter;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(financingListProvider.notifier).load());
  }

  Future<void> _approve(int id) async {
    final ok = await ConfirmDialog.show(context, title: 'Setujui', message: 'Setujui pembiayaan ini?', confirmLabel: 'Setujui', icon: Icons.check_circle);
    if (ok != true) return;
    try {
      await ref.read(financingServiceProvider).approve(id);
      if (mounted) context.showSuccessSnack('Pembiayaan disetujui');
      ref.read(financingListProvider.notifier).load(status: _filter);
    } on ApiException catch (e) {
      if (mounted) context.showSnack(e.firstError, isError: true);
    }
  }

  Future<void> _reject(int id) async {
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Pembiayaan'),
        content: AppTextField(label: 'Alasan Penolakan', controller: reasonCtrl, maxLines: 3),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, minimumSize: const Size(80, 40)),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
    if (confirmed != true || reasonCtrl.text.isEmpty) return;
    try {
      await ref.read(financingServiceProvider).reject(id, reasonCtrl.text);
      if (mounted) context.showSuccessSnack('Pembiayaan ditolak');
      ref.read(financingListProvider.notifier).load(status: _filter);
    } on ApiException catch (e) {
      if (mounted) context.showSnack(e.firstError, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(financingListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pembiayaan'),
        actions: [
          IconButton(
            onPressed: () => context.go('/admin/penalties'),
            icon: const Icon(Icons.money_off_rounded),
            tooltip: 'Manajemen Denda',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                for (final f in [null, 'pending', 'approved', 'rejected', 'completed'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(f?.toUpperCase() ?? 'SEMUA'),
                      selected: _filter == f,
                      onSelected: (_) {
                        setState(() => _filter = f);
                        ref.read(financingListProvider.notifier).load(status: f);
                      },
                      selectedColor: AppColors.primary.withOpacity(0.15),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(financingListProvider.notifier).load(status: _filter),
              child: state.isLoading && state.items.isEmpty
                  ? const ShimmerList()
                  : state.items.isEmpty
                      ? const EmptyState(icon: Icons.trending_up_rounded, title: 'Tidak ada pembiayaan')
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final f = state.items[i];
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardTheme.color,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.outline),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Expanded(child: Text(f.memberName ?? 'Anggota #${f.memberId}', style: const TextStyle(fontWeight: FontWeight.w700))),
                                    StatusBadge.fromStatus(f.status),
                                  ]),
                                  const SizedBox(height: 6),
                                  Text(f.amount.currency, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                                  Text('${f.type.toUpperCase()} • ${f.tenor} bulan • ${f.monthlyPayment.currency}/bln', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                                  if (f.purpose != null) Text('Tujuan: ${f.purpose}', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                                  if (f.isPending) ...[
                                    const SizedBox(height: 10),
                                    Row(children: [
                                      Expanded(child: AppButton(label: 'Setujui', onPressed: () => _approve(f.id), height: 40, color: AppColors.success)),
                                      const SizedBox(width: 8),
                                      Expanded(child: AppButton(label: 'Tolak', onPressed: () => _reject(f.id), height: 40, isOutlined: true, color: AppColors.error)),
                                    ]),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
