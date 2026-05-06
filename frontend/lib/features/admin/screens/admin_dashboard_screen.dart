import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/dashboard_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminDashboardProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final dashboard = ref.watch(adminDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard Admin', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            Text('Halo, ${user?.name ?? ''}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(adminDashboardProvider.notifier).load(),
        child: dashboard.when(
          loading: () => const SingleChildScrollView(
            child: Padding(padding: EdgeInsets.all(16), child: Column(children: [
              ShimmerLoading(height: 100), SizedBox(height: 12),
              ShimmerLoading(height: 100), SizedBox(height: 12),
              ShimmerLoading(height: 200),
            ])),
          ),
          error: (e, _) => Center(child: Text('$e')),
          data: (data) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    StatCard(title: 'Total Anggota', value: '${data.totalMembers}', icon: Icons.people_rounded, color: AppColors.primary, subtitle: '${data.activeMembers} aktif'),
                    StatCard(title: 'Total Tabungan', value: data.totalSavings.compact, icon: Icons.savings_rounded, color: AppColors.success),
                    StatCard(title: 'Total Pembiayaan', value: data.totalFinancings.compact, icon: Icons.trending_up_rounded, color: AppColors.info, subtitle: '${data.pendingFinancings} pending'),
                    StatCard(title: 'Dana Sosial', value: data.totalSocialFund.compact, icon: Icons.volunteer_activism_rounded, color: AppColors.secondary, subtitle: '${data.pendingApplications} pengajuan'),
                  ],
                ),
                const SizedBox(height: 24),

                // Chart
                if (data.monthlyStats.isNotEmpty) ...[
                  Text('Tren Bulanan', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  Container(
                    height: 220,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: data.monthlyStats.fold<double>(0, (max, s) {
                          final m = s.savings > s.financings ? s.savings : s.financings;
                          return m > max ? m : max;
                        }) * 1.2,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) {
                                final i = v.toInt();
                                if (i >= 0 && i < data.monthlyStats.length) {
                                  return Text(data.monthlyStats[i].month, style: const TextStyle(fontSize: 10));
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        barGroups: data.monthlyStats.asMap().entries.map((e) {
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(toY: e.value.savings, color: AppColors.primary, width: 10, borderRadius: BorderRadius.circular(4)),
                              BarChartRodData(toY: e.value.financings, color: AppColors.secondary, width: 10, borderRadius: BorderRadius.circular(4)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Legend(color: AppColors.primary, label: 'Tabungan'),
                      const SizedBox(width: 16),
                      _Legend(color: AppColors.secondary, label: 'Pembiayaan'),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
