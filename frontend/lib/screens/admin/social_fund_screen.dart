import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../services/api_service.dart';
import '../../utils/helpers.dart';

class SocialFundScreen extends StatefulWidget {
  const SocialFundScreen({super.key});
  @override
  State<SocialFundScreen> createState() => _SocialFundScreenState();
}

class _SocialFundScreenState extends State<SocialFundScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<dynamic> _funds = [];
  double _totalIn = 0;
  double _totalOut = 0;
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
      final result = await ApiService.get('/social-funds');
      if (mounted) setState(() {
        final data = result['data'];
        _funds = data['funds']?['data'] ?? [];
        _totalIn = double.tryParse('${data['total_in']}') ?? 0;
        _totalOut = double.tryParse('${data['total_out']}') ?? 0;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<dynamic> _filterByDirection(String? direction) {
    if (direction == null) return _funds;
    return _funds.where((f) => f['direction'] == direction).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : NestedScrollView(
              headerSliverBuilder: (_, __) => [
                SliverAppBar(
                  expandedHeight: 240,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dana Sosial', style: GoogleFonts.poppins(
                                fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                              const SizedBox(height: 4),
                              Text('Infaq, Bantuan & Kegiatan Sosial', style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.white70)),
                              const SizedBox(height: 16),
                              Row(children: [
                                Expanded(child: _balanceCard('Pemasukan', CurrencyHelper.format(_totalIn), Icons.arrow_downward, const Color(0xFF66BB6A))),
                                const SizedBox(width: 12),
                                Expanded(child: _balanceCard('Pengeluaran', CurrencyHelper.format(_totalOut), Icons.arrow_upward, const Color(0xFFEF5350))),
                              ]),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text('Saldo: ${CurrencyHelper.format(_totalIn - _totalOut)}',
                                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  bottom: TabBar(
                    controller: _tabCtrl,
                    indicatorColor: AppTheme.accentColor,
                    indicatorWeight: 3,
                    labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                    unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
                    tabs: const [Tab(text: 'Semua'), Tab(text: 'Masuk'), Tab(text: 'Keluar')],
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabCtrl,
                children: [
                  _buildList(_filterByDirection(null)),
                  _buildList(_filterByDirection('in')),
                  _buildList(_filterByDirection('out')),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: Text('Tambah', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _balanceCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withOpacity(0.3), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70)),
          Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
        ])),
      ]),
    );
  }

  Widget _buildList(List<dynamic> items) {
    if (items.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.volunteer_activism, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text('Belum ada data', style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
      ]));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, i) => _fundCard(items[i]),
      ),
    );
  }

  Widget _fundCard(Map<String, dynamic> f) {
    final isIn = f['direction'] == 'in';
    final typeLabel = _getTypeLabel(f['type'] ?? '');
    final color = isIn ? AppTheme.success : AppTheme.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            isIn ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            color: color, size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(typeLabel, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
          if (f['description'] != null)
            Text(f['description'], style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(DateHelper.format(f['transaction_date']),
            style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textLight)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${isIn ? '+' : '-'}${CurrencyHelper.format(f['amount'])}',
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          if (f['member'] != null)
            Text(f['member']['full_name'] ?? '', style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textLight)),
        ]),
      ]),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'infaq': return 'Infaq';
      case 'bantuan_sakit': return 'Bantuan Sakit';
      case 'kegiatan_sosial': return 'Kegiatan Sosial';
      case 'shu': return 'SHU';
      case 'lainnya': return 'Lainnya';
      default: return type;
    }
  }

  void _showAddDialog() {
    String type = 'infaq';
    String direction = 'in';
    final amountC = TextEditingController();
    final descC = TextEditingController();

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Tambah Dana Sosial', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Catat pemasukan atau pengeluaran dana sosial', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 20),

            // Direction toggle
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => setS(() => direction = 'in'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: direction == 'in' ? AppTheme.success.withOpacity(0.1) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: direction == 'in' ? AppTheme.success : Colors.transparent, width: 2),
                  ),
                  child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.arrow_downward, size: 18, color: direction == 'in' ? AppTheme.success : AppTheme.textLight),
                    const SizedBox(width: 6),
                    Text('Pemasukan', style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: direction == 'in' ? AppTheme.success : AppTheme.textLight)),
                  ])),
                ),
              )),
              const SizedBox(width: 12),
              Expanded(child: GestureDetector(
                onTap: () => setS(() => direction = 'out'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: direction == 'out' ? AppTheme.error.withOpacity(0.1) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: direction == 'out' ? AppTheme.error : Colors.transparent, width: 2),
                  ),
                  child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.arrow_upward, size: 18, color: direction == 'out' ? AppTheme.error : AppTheme.textLight),
                    const SizedBox(width: 6),
                    Text('Pengeluaran', style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: direction == 'out' ? AppTheme.error : AppTheme.textLight)),
                  ])),
                ),
              )),
            ]),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: type,
              decoration: const InputDecoration(labelText: 'Jenis', prefixIcon: Icon(Icons.category)),
              items: const [
                DropdownMenuItem(value: 'infaq', child: Text('Infaq')),
                DropdownMenuItem(value: 'bantuan_sakit', child: Text('Bantuan Sakit')),
                DropdownMenuItem(value: 'kegiatan_sosial', child: Text('Kegiatan Sosial')),
                DropdownMenuItem(value: 'shu', child: Text('SHU')),
                DropdownMenuItem(value: 'lainnya', child: Text('Lainnya')),
              ],
              onChanged: (v) => setS(() => type = v ?? 'infaq'),
            ),
            const SizedBox(height: 12),
            TextField(controller: amountC,
              decoration: const InputDecoration(labelText: 'Jumlah (Rp)', prefixIcon: Icon(Icons.money)),
              keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: descC,
              decoration: const InputDecoration(labelText: 'Keterangan', prefixIcon: Icon(Icons.description)),
              maxLines: 2),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  if (amountC.text.isEmpty) return;
                  try {
                    await ApiService.post('/social-funds', {
                      'type': type, 'amount': double.tryParse(amountC.text) ?? 0,
                      'description': descC.text, 'direction': direction,
                    });
                    if (mounted) Navigator.pop(ctx);
                    _load();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Dana sosial berhasil dicatat'), backgroundColor: AppTheme.success));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error));
                  }
                },
                child: Text('Simpan', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
      )),
    );
  }
}
