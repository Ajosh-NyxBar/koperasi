import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../services/api_service.dart';
import '../../utils/helpers.dart';

class FinancingListScreen extends StatefulWidget {
  const FinancingListScreen({super.key});
  @override
  State<FinancingListScreen> createState() => _FinancingListScreenState();
}

class _FinancingListScreenState extends State<FinancingListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<dynamic> _all = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final result = await ApiService.get('/financing');
      if (mounted) setState(() { _all = result['data']['data'] ?? []; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<dynamic> _filter(String status) => _all.where((f) => f['status'] == status).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembiayaan'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: [
            Tab(text: 'Pending (${_filter('pending').length})'),
            Tab(text: 'Aktif (${_filter('approved').length})'),
            Tab(text: 'Selesai (${_filter('completed').length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _buildList(_filter('pending'), true),
                _buildList(_filter('approved'), false),
                _buildList(_filter('completed'), false),
              ],
            ),
    );
  }

  Widget _buildList(List<dynamic> items, bool showActions) {
    if (items.isEmpty) {
      return Center(child: Text('Tidak ada data', style: GoogleFonts.poppins(color: AppTheme.textSecondary)));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, i) => _financingCard(items[i], showActions),
      ),
    );
  }

  Widget _financingCard(Map<String, dynamic> f, bool showActions) {
    final memberName = f['member']?['full_name'] ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(f['item_name'] ?? '', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
            Text(memberName, style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary)),
          ])),
        ]),
        const Divider(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Total', style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary)),
            Text(CurrencyHelper.format(f['total_price']), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('Cicilan/bln', style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary)),
            Text(CurrencyHelper.format(f['monthly_installment']), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
          ]),
        ]),
        if (showActions) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () async {
                try {
                  await ApiService.put('/financing/${f['id']}/reject', {});
                  _load();
                } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
              },
              style: OutlinedButton.styleFrom(foregroundColor: AppTheme.error, side: const BorderSide(color: AppTheme.error)),
              child: const Text('Tolak'),
            )),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: () async {
                try {
                  await ApiService.put('/financing/${f['id']}/approve', {});
                  _load();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pembiayaan disetujui'), backgroundColor: AppTheme.success));
                } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
              },
              child: const Text('Setujui'),
            )),
          ]),
        ],
      ]),
    );
  }
}
