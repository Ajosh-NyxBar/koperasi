import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/app_theme.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/helpers.dart';
import '../login_screen.dart';
import 'member_list_screen.dart';
import 'product_list_screen.dart';
import 'financing_list_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final result = await ApiService.get('/dashboard/admin');
      final name = await AuthService.getUserName();
      if (mounted) setState(() { _data = result['data']; _userName = name ?? 'Admin'; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(onRefresh: _loadData, child: _buildContent()),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        // Header
        SliverAppBar(
          expandedHeight: 200, pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24, backgroundColor: Colors.white24,
                            child: Text(_userName.isNotEmpty ? _userName[0].toUpperCase() : 'A',
                              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Selamat Datang,', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
                                Text(_userName, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                              ],
                            ),
                          ),
                          IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: _logout),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Dashboard Admin - Koperasi Konsumen Bina Mutiara Terpadu', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white60)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Stats Cards
        SliverToBoxAdapter(child: _buildStatsSection()),

        // Quick Actions
        SliverToBoxAdapter(child: _buildQuickActions()),

        // Chart
        SliverToBoxAdapter(child: _buildChart()),

        SliverToBoxAdapter(child: const SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildStatsSection() {
    if (_data == null) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkasan', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _statCard('Total Anggota', '${_data!['total_members']}', Icons.people, AppTheme.primaryColor)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Pembiayaan Aktif', '${_data!['active_financing']}', Icons.trending_up, AppTheme.info)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _statCard('Total Tabungan', CurrencyHelper.formatCompact(_data!['total_savings']), Icons.savings, AppTheme.success)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Dana Sosial', CurrencyHelper.formatCompact(_data!['social_fund_balance']), Icons.volunteer_activism, AppTheme.warning)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _statCard('Simpanan Wajib', CurrencyHelper.formatCompact(_data!['total_mandatory_savings']), Icons.account_balance_wallet, const Color(0xFF7B1FA2))),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Pending', '${_data!['pending_financing']}', Icons.hourglass_empty, AppTheme.error)),
          ]),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 2),
          Text(title, style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Menu Cepat', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _actionTile('Anggota', Icons.people_alt, AppTheme.primaryColor, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MemberListScreen()));
            })),
            const SizedBox(width: 12),
            Expanded(child: _actionTile('Produk', Icons.inventory_2, AppTheme.info, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListScreen()));
            })),
            const SizedBox(width: 12),
            Expanded(child: _actionTile('Pembiayaan', Icons.credit_card, AppTheme.success, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FinancingListScreen()));
            })),
            const SizedBox(width: 12),
            Expanded(child: _actionTile('Sosial', Icons.volunteer_activism, AppTheme.warning, () {})),
          ]),
        ],
      ),
    );
  }

  Widget _actionTile(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    final stats = _data?['monthly_stats'] as List<dynamic>? ?? [];
    if (stats.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pendapatan 6 Bulan', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: stats.asMap().entries.map((e) {
                    final val = (double.tryParse('${e.value['installment_income']}') ?? 0) / 1000;
                    return BarChartGroupData(x: e.key, barRods: [
                      BarChartRodData(toY: val, color: AppTheme.primaryColor, width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
                    ]);
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, _) {
                      final idx = val.toInt();
                      if (idx < stats.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(stats[idx]['label']?.toString().split(' ').first ?? '', style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textSecondary)),
                        );
                      }
                      return const Text('');
                    })),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (val, _) {
                      return Text('${val.toInt()}K', style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textSecondary));
                    })),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 100),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
