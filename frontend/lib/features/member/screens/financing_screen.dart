import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../providers/financing_provider.dart';

class FinancingScreen extends ConsumerStatefulWidget {
  const FinancingScreen({super.key});

  @override
  ConsumerState<FinancingScreen> createState() => _FinancingScreenState();
}

class _FinancingScreenState extends ConsumerState<FinancingScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(financingListProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(financingListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembiayaan'),
        actions: [
          IconButton(icon: const Icon(Icons.calculate_rounded), onPressed: () => context.push('/member/financings-simulate')),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/member/financings-apply'),
        icon: const Icon(Icons.add),
        label: const Text('Ajukan'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(financingListProvider.notifier).load(),
        child: state.isLoading && state.items.isEmpty
            ? const ShimmerList()
            : state.items.isEmpty
                ? const EmptyState(icon: Icons.trending_up_rounded, title: 'Belum ada pembiayaan')
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final f = state.items[i];
                      return InkWell(
                        onTap: () => context.push('/member/financings/${f.id}'),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(16),
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
                                  Expanded(
                                    child: Text(f.type.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                  ),
                                  StatusBadge.fromStatus(f.status),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(f.amount.currency, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              Text('${f.tenor} bulan • Cicilan ${f.monthlyPayment.currency}/bln', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                              if (f.isApproved && f.progress != null) ...[
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: f.progress! / 100,
                                    backgroundColor: AppColors.outline,
                                    color: AppColors.primary,
                                    minHeight: 6,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('Progress: ${f.progress!.toStringAsFixed(0)}%', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
