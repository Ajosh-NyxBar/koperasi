import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/saving_model.dart';
import '../../../data/services/saving_service.dart';
import '../../../providers/auth_provider.dart';

final _savingTxProvider = StateProvider<AsyncValue<List<SavingTransaction>>>((ref) => const AsyncValue.loading());
final _mandatoryProvider = StateProvider<AsyncValue<List<MandatorySaving>>>((ref) => const AsyncValue.loading());

class SavingScreen extends ConsumerStatefulWidget {
  const SavingScreen({super.key});

  @override
  ConsumerState<SavingScreen> createState() => _SavingScreenState();
}

class _SavingScreenState extends ConsumerState<SavingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    Future.microtask(() => _loadAll());
  }

  int get _memberId => ref.read(authProvider).user?.member?.id ?? 0;

  Future<void> _loadAll() async {
    final svc = ref.read(savingServiceProvider);
    final mid = _memberId;
    try {
      final txs = await svc.getTransactions(mid);
      ref.read(_savingTxProvider.notifier).state = AsyncValue.data(txs.items);
    } catch (e, st) {
      ref.read(_savingTxProvider.notifier).state = AsyncValue.error(e, st);
    }
    try {
      final ms = await svc.getMandatorySavings(mid);
      ref.read(_mandatoryProvider.notifier).state = AsyncValue.data(ms);
    } catch (e, st) {
      ref.read(_mandatoryProvider.notifier).state = AsyncValue.error(e, st);
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabungan'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [Tab(text: 'Transaksi'), Tab(text: 'Simpanan Wajib')],
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _TransactionTab(onRefresh: _loadAll),
          _MandatoryTab(onRefresh: _loadAll),
        ],
      ),
    );
  }
}

class _TransactionTab extends ConsumerWidget {
  final Future<void> Function() onRefresh;
  const _TransactionTab({required this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_savingTxProvider);
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: state.when(
        loading: () => const ShimmerList(),
        error: (e, _) => Center(child: Text('$e')),
        data: (txs) {
          if (txs.isEmpty) return const EmptyState(icon: Icons.savings_outlined, title: 'Belum ada transaksi');
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: txs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final tx = txs[i];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (tx.isDeposit ? AppColors.success : AppColors.error).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        tx.isDeposit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                        color: tx.isDeposit ? AppColors.success : AppColors.error,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tx.type == 'deposit' ? 'Setoran' : 'Penarikan', style: const TextStyle(fontWeight: FontWeight.w600)),
                          if (tx.note != null) Text(tx.note!, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                          Text(tx.createdAt.withTime, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${tx.isDeposit ? '+' : '-'}${tx.amount.currency}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: tx.isDeposit ? AppColors.success : AppColors.error,
                          ),
                        ),
                        Text('Saldo: ${tx.balanceAfter.currency}', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
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
