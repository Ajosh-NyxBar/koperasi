import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/saving_model.dart';
import '../../../data/services/saving_service.dart';

final _balanceProvider = StateProvider<AsyncValue<SavingBalance>>((ref) => const AsyncValue.loading());
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

  Future<void> _loadAll() async {
    final svc = ref.read(savingServiceProvider);
    try {
      final balance = await svc.getBalance();
      ref.read(_balanceProvider.notifier).state = AsyncValue.data(balance);
    } catch (e, st) {
      ref.read(_balanceProvider.notifier).state = AsyncValue.error(e, st);
    }
    try {
      final ms = await svc.getMandatorySavings();
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
      body: Column(
        children: [
          const _BalanceHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _TransactionTab(onRefresh: _loadAll),
                _MandatoryTab(onRefresh: _loadAll),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceHeader extends ConsumerWidget {
  const _BalanceHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_balanceProvider);
    final balance = state.maybeWhen(data: (b) => b.balance, orElse: () => null);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.account_balance_wallet_rounded, color: Colors.white70, size: 18),
              SizedBox(width: 8),
              Text('Saldo Tabungan', style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          balance == null
              ? const ShimmerLoading(height: 28, width: 120)
              : Text(
                  balance.currency,
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700),
                ),
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
    final state = ref.watch(_balanceProvider);
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: state.when(
        loading: () => const ShimmerList(),
        error: (e, _) => _ErrorView(message: '$e', onRetry: onRefresh),
        data: (balance) {
          final txs = balance.transactions.items;
          if (txs.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 80),
                EmptyState(icon: Icons.savings_outlined, title: 'Belum ada transaksi'),
              ],
            );
          }
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
                          Text(tx.typeLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                          if (tx.note != null && tx.note!.isNotEmpty)
                            Text(tx.note!, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                          Text(tx.transactionDate.formatted, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
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
        error: (e, _) => _ErrorView(message: '$e', onRetry: onRefresh),
        data: (items) {
          if (items.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 80),
                EmptyState(icon: Icons.calendar_month, title: 'Belum ada simpanan wajib'),
              ],
            );
          }
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
                    StatusBadge.fromStatus(ms.status),
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

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 40),
                const SizedBox(height: 12),
                Text(message, textAlign: TextAlign.center, style: TextStyle(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
