import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../data/models/dashboard_model.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: RefreshIndicator(
          color: Colors.white,
          backgroundColor: AppColors.primary,
          onRefresh: () => ref.read(memberDashboardProvider.notifier).load(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header ──
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      child: Column(
                        children: [
                          // Top row: avatar + name + icons
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                child: Text(
                                  ((user != null && user.name.isNotEmpty) ? user.name[0] : 'U').toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Assalamualaikum,',
                                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                                    ),
                                    Text(
                                      user?.name ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              _HeaderIcon(
                                icon: Icons.notifications_outlined,
                                onTap: () => context.push('/member/notifications'),
                              ),
                              const SizedBox(width: 4),
                              _HeaderIcon(
                                icon: Icons.logout_rounded,
                                onTap: () => _confirmLogout(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Balance card
                          dashboard.when(
                            loading: () => _buildBalanceCardShimmer(),
                            error: (_, __) => _buildBalanceCardError(),
                            data: (data) => _buildBalanceCard(context, data, user?.member?.memberId),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Body ──
              SliverToBoxAdapter(
                child: dashboard.when(
                  loading: () => const _DashboardBodyShimmer(),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error.withOpacity(0.6)),
                          const SizedBox(height: 12),
                          Text('$e', textAlign: TextAlign.center, style: TextStyle(color: AppColors.onSurfaceVariant)),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () => ref.read(memberDashboardProvider.notifier).load(),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (data) => _buildBody(context, data, isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, MemberDashboard data, String? memberId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              const Text('Saldo Tabungan', style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              data.savingBalance.currency,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 28,
              ),
            ),
          ),
          if (memberId != null && memberId.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'No. Anggota: $memberId',
              style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 11),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _BalanceChip(label: 'Simpanan Pokok', value: data.principalSaving.currency)),
              const SizedBox(width: 8),
              Expanded(child: _BalanceChip(label: 'Total Pembiayaan', value: data.totalFinancing.currency)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCardShimmer() {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }

  Widget _buildBalanceCardError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text('Gagal memuat saldo', style: TextStyle(color: Colors.white70, fontSize: 13)),
    );
  }

  Widget _buildBody(BuildContext context, MemberDashboard data, bool isDark) {
    final borderColor = isDark ? AppColors.darkOutline : AppColors.outline;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.surface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats Row
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: Icons.receipt_long_rounded,
                  color: AppColors.info,
                  title: 'Cicilan Aktif',
                  value: '${data.activeInstallments}',
                  borderColor: borderColor,
                  cardColor: cardColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  icon: Icons.calendar_month_rounded,
                  color: data.unpaidMandatory > 0 ? AppColors.warning : AppColors.success,
                  title: 'Simpanan Wajib',
                  value: data.unpaidMandatory > 0 ? '${data.unpaidMandatory} belum' : 'Lunas',
                  borderColor: borderColor,
                  cardColor: cardColor,
                ),
              ),
            ],
          ),

          // Next installment info
          if (data.nextInstallmentDue != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.brown.shade800, fontSize: 12.5),
                        children: [
                          const TextSpan(text: 'Cicilan berikutnya '),
                          TextSpan(
                            text: data.nextInstallmentAmount.currency,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: ' — jatuh tempo ${data.nextInstallmentDue!.formatted}'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Quick Actions
          Text('Aksi Cepat', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              _QuickAction(
                icon: Icons.calculate_rounded,
                label: 'Simulasi',
                color: AppColors.info,
                borderColor: borderColor,
                cardColor: cardColor,
                onTap: () => context.push('/member/financings-simulate'),
              ),
              const SizedBox(width: 12),
              _QuickAction(
                icon: Icons.request_page_rounded,
                label: 'Ajukan\nPembiayaan',
                color: AppColors.primary,
                borderColor: borderColor,
                cardColor: cardColor,
                onTap: () => context.push('/member/financings-apply'),
              ),
              const SizedBox(width: 12),
              _QuickAction(
                icon: Icons.volunteer_activism_rounded,
                label: 'Dana\nSosial',
                color: AppColors.secondary,
                borderColor: borderColor,
                cardColor: cardColor,
                onTap: () => context.push('/member/social-fund'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Transactions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Transaksi Terbaru', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              if (data.recentTransactions.isNotEmpty)
                TextButton(
                  onPressed: () => context.push('/member/savings'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Lihat semua', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (data.recentTransactions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 40, color: AppColors.onSurfaceVariant.withOpacity(0.4)),
                  const SizedBox(height: 8),
                  const Text('Belum ada transaksi', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                ],
              ),
            )
          else
            ...data.recentTransactions.map((t) => _TransactionTile(t: t, borderColor: borderColor, cardColor: cardColor)),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            child: Text('Keluar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ── Small widgets ──

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, color: Colors.white, size: 20),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 10)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final Color borderColor;
  final Color cardColor;
  const _MiniStat({required this.icon, required this.color, required this.title, required this.value, required this.borderColor, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: color)),
                Text(title, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color borderColor;
  final Color cardColor;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.borderColor, required this.cardColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, height: 1.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final RecentTransaction t;
  final Color borderColor;
  final Color cardColor;
  const _TransactionTile({required this.t, required this.borderColor, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    final isDeposit = t.type == 'deposit';
    final color = isDeposit ? AppColors.success : AppColors.info;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isDeposit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(t.date.relative, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isDeposit ? '+' : '-'}${t.amount.currency}',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color),
          ),
        ],
      ),
    );
  }
}

class _DashboardBodyShimmer extends StatelessWidget {
  const _DashboardBodyShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: ShimmerLoading(height: 70, borderRadius: 14)),
            const SizedBox(width: 12),
            Expanded(child: ShimmerLoading(height: 70, borderRadius: 14)),
          ]),
          const SizedBox(height: 24),
          const ShimmerLoading(height: 16, width: 100),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: ShimmerLoading(height: 90, borderRadius: 14)),
            const SizedBox(width: 12),
            Expanded(child: ShimmerLoading(height: 90, borderRadius: 14)),
            const SizedBox(width: 12),
            Expanded(child: ShimmerLoading(height: 90, borderRadius: 14)),
          ]),
          const SizedBox(height: 24),
          const ShimmerLoading(height: 16, width: 120),
          const SizedBox(height: 12),
          ...List.generate(3, (_) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ShimmerLoading(height: 60, borderRadius: 14),
              )),
        ],
      ),
    );
  }
}
