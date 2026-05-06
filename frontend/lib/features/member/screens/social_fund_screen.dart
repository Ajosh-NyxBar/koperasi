import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/models/social_fund_model.dart';
import '../../../data/services/social_fund_service.dart';

final _appsProvider = StateProvider<AsyncValue<List<SocialFundApplication>>>((ref) => const AsyncValue.loading());

class SocialFundScreen extends ConsumerStatefulWidget {
  const SocialFundScreen({super.key});

  @override
  ConsumerState<SocialFundScreen> createState() => _SocialFundScreenState();
}

class _SocialFundScreenState extends ConsumerState<SocialFundScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    try {
      final result = await ref.read(socialFundServiceProvider).getApplications();
      ref.read(_appsProvider.notifier).state = AsyncValue.data(result.items);
    } catch (e, st) {
      ref.read(_appsProvider.notifier).state = AsyncValue.error(e, st);
    }
  }

  void _showApplySheet() {
    final reasonCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ajukan Bantuan', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            AppTextField(label: 'Alasan', hint: 'Jelaskan alasan bantuan', controller: reasonCtrl, maxLines: 3),
            const SizedBox(height: 12),
            AppTextField(label: 'Jumlah (Rp)', hint: 'Masukkan jumlah', controller: amountCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            AppButton(
              label: 'Kirim Pengajuan',
              onPressed: () async {
                try {
                  await ref.read(socialFundServiceProvider).applyForAid(FormData.fromMap({
                    'reason': reasonCtrl.text,
                    'amount': double.tryParse(amountCtrl.text) ?? 0,
                  }));
                  if (mounted) {
                    Navigator.pop(ctx);
                    context.showSuccessSnack('Pengajuan berhasil dikirim');
                    _load();
                  }
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
    final apps = ref.watch(_appsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dana Sosial')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showApplySheet,
        icon: const Icon(Icons.add),
        label: const Text('Ajukan'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: apps.when(
          loading: () => const ShimmerList(),
          error: (e, _) => Center(child: Text('$e')),
          data: (items) {
            if (items.isEmpty) return const EmptyState(icon: Icons.volunteer_activism_rounded, title: 'Belum ada pengajuan');
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final app = items[i];
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
                      Row(
                        children: [
                          Expanded(child: Text(app.reason, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis)),
                          StatusBadge.fromStatus(app.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(app.amount.currency, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      Text(app.createdAt.formatted, style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                      if (app.adminNote != null) ...[
                        const SizedBox(height: 4),
                        Text('Admin: ${app.adminNote}', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, fontStyle: FontStyle.italic)),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
