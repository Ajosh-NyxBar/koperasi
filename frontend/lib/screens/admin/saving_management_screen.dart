import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../services/api_service.dart';
import '../../utils/helpers.dart';

class SavingManagementScreen extends StatefulWidget {
  const SavingManagementScreen({super.key});
  @override
  State<SavingManagementScreen> createState() => _SavingManagementScreenState();
}

class _SavingManagementScreenState extends State<SavingManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<dynamic> _savings = [];
  List<dynamic> _mandatorySavings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final sResult = await ApiService.get('/admin/savings');
      final mResult = await ApiService.get('/admin/mandatory-savings');
      if (mounted) setState(() {
        _savings = sResult['data']?['data'] ?? [];
        _mandatorySavings = mResult['data']?['data'] ?? [];
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 160,
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
                        Text('Kelola Simpanan', style: GoogleFonts.poppins(
                          fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('Tabungan & Simpanan Wajib Anggota', style: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.white70)),
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
              tabs: const [Tab(text: 'Tabungan'), Tab(text: 'Simpanan Wajib')],
            ),
          ),
        ],
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabCtrl,
                children: [_buildSavingsList(), _buildMandatoryList()],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showDepositDialog,
        icon: const Icon(Icons.add),
        label: Text('Setor/Tarik', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildSavingsList() {
    if (_savings.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.savings, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text('Belum ada data tabungan', style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
      ]));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _savings.length,
        itemBuilder: (_, i) => _savingTile(_savings[i]),
      ),
    );
  }

  Widget _savingTile(Map<String, dynamic> s) {
    final memberName = s['member']?['full_name'] ?? '-';
    final balance = double.tryParse('${s['balance']}') ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(children: [
        CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: Text(memberName.isNotEmpty ? memberName[0].toUpperCase() : '?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(memberName, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
          Text(s['member']?['member_code'] ?? '', style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(CurrencyHelper.format(balance),
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
          Text('Saldo', style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textLight)),
        ]),
      ]),
    );
  }

  Widget _buildMandatoryList() {
    if (_mandatorySavings.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.calendar_month, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text('Belum ada data simpanan wajib', style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
      ]));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mandatorySavings.length,
        itemBuilder: (_, i) => _mandatoryTile(_mandatorySavings[i]),
      ),
    );
  }

  Widget _mandatoryTile(Map<String, dynamic> m) {
    final memberName = m['member']?['full_name'] ?? '-';
    final isPaid = m['status'] == 'paid';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isPaid ? AppTheme.success.withOpacity(0.1) : AppTheme.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isPaid ? Icons.check_circle : Icons.hourglass_empty,
            color: isPaid ? AppTheme.success : AppTheme.warning, size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(memberName, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
          Text('Periode: ${DateHelper.formatMonthYear(m['period'])}',
            style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(CurrencyHelper.format(m['amount']),
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700,
              color: isPaid ? AppTheme.success : AppTheme.warning)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isPaid ? AppTheme.success.withOpacity(0.1) : AppTheme.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(isPaid ? 'Lunas' : 'Belum',
              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600,
                color: isPaid ? AppTheme.success : AppTheme.warning)),
          ),
        ]),
      ]),
    );
  }

  void _showDepositDialog() {
    String action = 'deposit';
    final memberIdC = TextEditingController();
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
            Text('Setor / Tarik Tabungan', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),

            // Action toggle
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => setS(() => action = 'deposit'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: action == 'deposit' ? AppTheme.success.withOpacity(0.1) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: action == 'deposit' ? AppTheme.success : Colors.transparent, width: 2),
                  ),
                  child: Center(child: Text('Setor', style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: action == 'deposit' ? AppTheme.success : AppTheme.textLight))),
                ),
              )),
              const SizedBox(width: 12),
              Expanded(child: GestureDetector(
                onTap: () => setS(() => action = 'withdraw'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: action == 'withdraw' ? AppTheme.error.withOpacity(0.1) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: action == 'withdraw' ? AppTheme.error : Colors.transparent, width: 2),
                  ),
                  child: Center(child: Text('Tarik', style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: action == 'withdraw' ? AppTheme.error : AppTheme.textLight))),
                ),
              )),
            ]),
            const SizedBox(height: 16),
            TextField(controller: memberIdC,
              decoration: const InputDecoration(labelText: 'ID Anggota', prefixIcon: Icon(Icons.person)),
              keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: amountC,
              decoration: const InputDecoration(labelText: 'Jumlah (Rp)', prefixIcon: Icon(Icons.money)),
              keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: descC,
              decoration: const InputDecoration(labelText: 'Keterangan', prefixIcon: Icon(Icons.description))),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: action == 'deposit' ? AppTheme.success : AppTheme.error,
                ),
                onPressed: () async {
                  if (memberIdC.text.isEmpty || amountC.text.isEmpty) return;
                  try {
                    final endpoint = action == 'deposit' ? '/savings/deposit' : '/savings/withdraw';
                    await ApiService.post(endpoint, {
                      'member_id': int.tryParse(memberIdC.text) ?? 0,
                      'amount': double.tryParse(amountC.text) ?? 0,
                      'description': descC.text,
                    });
                    if (mounted) Navigator.pop(ctx);
                    _load();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(action == 'deposit' ? 'Setor berhasil' : 'Tarik berhasil'),
                        backgroundColor: AppTheme.success));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error));
                  }
                },
                child: Text(action == 'deposit' ? 'Setor Tabungan' : 'Tarik Tabungan',
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
      )),
    );
  }
}
