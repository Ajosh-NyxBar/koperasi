import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/dashboard_provider.dart';

class MemberDashboardScreen extends ConsumerStatefulWidget {
  const MemberDashboardScreen({super.key});

  @override
  ConsumerState<MemberDashboardScreen> createState() => _MemberDashboardScreenState();
}

class _MemberDashboardScreenState extends ConsumerState<MemberDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(memberDashboardProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final dashboard = ref.watch(memberDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Halo, ${user?.name ?? ''}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            Text(user?.member?.memberId ?? '', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/member/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(memberDashboardProvider.notifier).load(),
        child: dashboard.when(
          loading: () => const SingleChildScrollView(child: _DashboardShimmer()),
          error: (e, _) => Center(child: Text('$e')),
          data: (data) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Saldo Tabungan', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        data.savingBalance.currency,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _BalanceChip(label: 'Pokok', value: data.principalSaving.currency),
                          const SizedBox(width: 12),
                          _BalanceChip(label: 'Pembiayaan', value: data.totalFinancing.currency),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Quick Stats
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    StatCard(
                      title: 'Cicilan Aktif',
                      value: '${data.activeInstallments}',
                      icon: Icons.receipt_long_rounded,
                      color: AppColors.info,
                    ),
                    StatCard(
                      title: 'Simpanan Wajib',
                      value: '${data.unpaidMandatory} belum',
                      icon: Icons.calendar_month_rounded,
                      color: data.unpaidMandatory > 0 ? AppColors.warning : AppColors.success,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Quick Actions
                Text('Aksi Cepat', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _QuickAction(icon: Icons.calculate_rounded, label: 'Simulasi', onTap: () => context.push('/member/financings-simulate')),
                    const SizedBox(width: 12),
                    _QuickAction(icon: Icons.request_page_rounded, label: 'Ajukan', onTap: () => context.push('/member/financings-apply')),
                    const SizedBox(width: 12),
                    _QuickAction(icon: Icons.volunteer_activism_rounded, label: 'Dana Sosial', onTap: () => context.push('/member/social-fund')),
                  ],
                ),
                const SizedBox(height: 24),

                // Recent Transactions
                Text('Transaksi Terbaru', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                if (data.recentTransactions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: const Center(child: Text('Belum ada transaksi', style: TextStyle(color: AppColors.onSurfaceVariant))),
                  )
                else
                  ...data.recentTransactions.map((t) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
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
                                color: (t.type == 'deposit' ? AppColors.success : AppColors.info).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                t.type == 'deposit' ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                color: t.type == 'deposit' ? AppColors.success : AppColors.info,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  Text(t.date.relative, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                                ],
                              ),
                            ),
                            Text(t.amount.currency, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ],
                        ),
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BalanceChip extends StatelessWidget {
  final String label;
  final String value;
  const _BalanceChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.outline),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardShimmer extends StatelessWidget {
  const _DashboardShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const ShimmerLoading(height: 160, borderRadius: 20),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: ShimmerLoading(height: 100)),
            const SizedBox(width: 12),
            Expanded(child: ShimmerLoading(height: 100)),
          ]),
          const SizedBox(height: 24),
          const ShimmerLoading(height: 20, width: 120),
          const SizedBox(height: 12),
          ...List.generate(3, (_) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ShimmerLoading(height: 60),
              )),
        ],
      ),
    );
  }
}
