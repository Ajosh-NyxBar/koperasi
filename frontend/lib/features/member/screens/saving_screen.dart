import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/saving_model.dart';
import '../../../data/services/saving_service.dart';

final _mandatoryProvider = StateProvider<AsyncValue<List<MandatorySaving>>>((ref) => const AsyncValue.loading());

class SavingScreen extends ConsumerStatefulWidget {
  const SavingScreen({super.key});

  @override
  ConsumerState<SavingScreen> createState() => _SavingScreenState();
}

class _SavingScreenState extends ConsumerState<SavingScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadAll());
  }

  Future<void> _loadAll() async {
    final svc = ref.read(savingServiceProvider);
    // TODO: backend belum punya endpoint riwayat transaksi simpanan; tab Transaksi dihapus.
    try {
      final ms = await svc.getMandatorySavings();
      ref.read(_mandatoryProvider.notifier).state = AsyncValue.data(ms);
    } catch (e, st) {
      ref.read(_mandatoryProvider.notifier).state = AsyncValue.error(e, st);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simpanan Wajib'),
      ),
      body: _MandatoryTab(onRefresh: _loadAll),
    );
  }
}

class _MandatoryTab extends ConsumerWidget {
  final Future<void> Function() onRefresh;
  const _MandatoryTab({required this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_mandatoryProvider);
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: state.when(
        loading: () => const ShimmerList(),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) {
          if (items.isEmpty) return const EmptyState(icon: Icons.calendar_month, title: 'Belum ada simpanan wajib');
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final ms = items[i];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ms.period, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(ms.amount.currency, style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
                          Text('Jatuh tempo: ${ms.dueDate.formatted}', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    StatusBadge.fromStatus(ms.isPaid ? 'paid' : 'pending'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
