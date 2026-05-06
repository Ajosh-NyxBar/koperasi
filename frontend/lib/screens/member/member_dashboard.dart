import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/helpers.dart';
import '../login_screen.dart';

class MemberDashboard extends StatefulWidget {
  const MemberDashboard({super.key});
  @override
  State<MemberDashboard> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String _userName = '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final result = await ApiService.get('/dashboard/member');
      final name = await AuthService.getUserName();
      if (mounted) setState(() { _data = result['data']; _userName = name ?? ''; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(onRefresh: _loadData, child: _buildBody()),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: return _buildHome();
      case 1: return _buildSavings();
      case 2: return _buildFinancing();
      case 3: return _buildProfile();
      default: return _buildHome();
    }
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textLight,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.savings_rounded), label: 'Simpanan'),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card_rounded), label: 'Pembiayaan'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),
    );
  }

  // =================== HOME TAB ===================
  Widget _buildHome() {
    final member = _data?['member'];
    final savingBalance = _data?['saving_balance'] ?? 0;
    final financings = _data?['active_financings'] as List<dynamic>? ?? [];
    final nextInstallment = _data?['next_installment'];

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220, pinned: true, automaticallyImplyLeading: false,
          actions: [
            IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () {}),
            IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: () async {
              await AuthService.logout();
              if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            }),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Row(children: [
                        CircleAvatar(radius: 24, backgroundColor: Colors.white24,
                          child: Text(_userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white))),
                        const SizedBox(width: 12),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Assalamualaikum,', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
                          Text(_userName, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                        ]),
                      ]),
                      const SizedBox(height: 20),
                      // Balance Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Saldo Tabungan', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
                            const SizedBox(height: 4),
                            Text(CurrencyHelper.format(savingBalance),
                              style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                            if (member != null) ...[
                              const SizedBox(height: 4),
                              Text('No. Anggota: ${member['member_code']}',
                                style: GoogleFonts.poppins(fontSize: 11, color: Colors.white60)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Next installment
        if (nextInstallment != null) SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.warning.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.event, color: AppTheme.warning, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Cicilan Berikutnya', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  Text('${CurrencyHelper.format(nextInstallment['amount'])} - ${DateHelper.format(nextInstallment['due_date'])}',
                    style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary)),
                ])),
              ]),
            ),
          ),
        ),

        // Active Financing
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pembiayaan Aktif', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                if (financings.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Center(child: Column(children: [
                      Icon(Icons.check_circle_outline, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Text('Tidak ada pembiayaan aktif', style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary)),
                    ])),
                  )
                else
                  ...financings.map((f) => _financingCard(f)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _financingCard(Map<String, dynamic> f) {
    final totalPaid = double.tryParse('${f['total_paid']}') ?? 0;
    final totalPrice = double.tryParse('${f['total_price']}') ?? 1;
    final progress = totalPrice > 0 ? totalPaid / totalPrice : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.shopping_bag, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(f['item_name'] ?? '', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600))),
            _statusBadge(f['status'] ?? ''),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Total: ${CurrencyHelper.format(f['total_price'])}', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary)),
            Text('Cicilan: ${CurrencyHelper.format(f['monthly_installment'])}/bln', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: Colors.grey.shade200, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 4),
          Text('${(progress * 100).toStringAsFixed(0)}% terbayar', style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'approved': color = AppTheme.success; label = 'Aktif'; break;
      case 'pending': color = AppTheme.warning; label = 'Pending'; break;
      case 'completed': color = AppTheme.info; label = 'Lunas'; break;
      case 'rejected': color = AppTheme.error; label = 'Ditolak'; break;
      default: color = AppTheme.textSecondary; label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }

  // =================== SAVINGS TAB ===================
  Widget _buildSavings() {
    final savingBalance = _data?['saving_balance'] ?? 0;
    final principalSaving = _data?['principal_saving'];
    final totalMandatory = _data?['total_mandatory_savings'] ?? 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SafeArea(child: const SizedBox()),
        Text('Simpanan Saya', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        // Tabungan Card
        _savingCard('Tabungan Pribadi', CurrencyHelper.format(savingBalance), Icons.savings, AppTheme.primaryColor,
          'Tabungan yang bisa ditarik kapan saja'),
        _savingCard('Simpanan Pokok', CurrencyHelper.format(principalSaving?['amount'] ?? 0), Icons.account_balance, AppTheme.info,
          'Dibayar 1x saat pendaftaran • Status: ${principalSaving?['status'] ?? '-'}'),
        _savingCard('Simpanan Wajib', CurrencyHelper.format(totalMandatory), Icons.calendar_month, const Color(0xFF7B1FA2),
          'Total simpanan wajib bulanan'),
      ],
    );
  }

  Widget _savingCard(String title, String amount, IconData icon, Color color, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(amount, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 2),
          Text(desc, style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textLight)),
        ])),
      ]),
    );
  }

  // =================== FINANCING TAB ===================
  Widget _buildFinancing() {
    final financings = _data?['active_financings'] as List<dynamic>? ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SafeArea(child: const SizedBox()),
        Text('Pembiayaan Saya', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        if (financings.isEmpty)
          Center(child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(children: [
              Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text('Belum ada pembiayaan', style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary)),
            ]),
          ))
        else
          ...financings.map((f) => _financingDetailCard(f as Map<String, dynamic>)),
      ],
    );
  }

  Widget _financingDetailCard(Map<String, dynamic> f) {
    final installments = f['installments'] as List<dynamic>? ?? [];
    final paid = installments.where((i) => i['status'] == 'paid').length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(f['item_name'] ?? '', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700))),
          _statusBadge(f['status'] ?? ''),
        ]),
        const Divider(height: 20),
        _infoRow('Harga Barang', CurrencyHelper.format(f['base_price'])),
        _infoRow('Margin', '${f['margin_percentage']}%'),
        _infoRow('Total Harga', CurrencyHelper.format(f['total_price'])),
        _infoRow('Tenor', '${f['tenor']} bulan'),
        _infoRow('Cicilan/bulan', CurrencyHelper.format(f['monthly_installment'])),
        _infoRow('Terbayar', '${CurrencyHelper.format(f['total_paid'])} ($paid/${installments.length})'),
        _infoRow('Sisa', CurrencyHelper.format(f['remaining'])),
      ]),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary)),
        Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
      ]),
    );
  }

  // =================== PROFILE TAB ===================
  Widget _buildProfile() {
    final member = _data?['member'] as Map<String, dynamic>?;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SafeArea(child: const SizedBox()),
        Center(child: Column(children: [
          CircleAvatar(radius: 40, backgroundColor: AppTheme.primaryColor,
            child: Text(_userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
              style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white))),
          const SizedBox(height: 12),
          Text(_userName, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
          Text(member?['member_code'] ?? '', style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary)),
        ])),
        const SizedBox(height: 24),
        if (member != null) ...[
          _profileItem(Icons.badge, 'NIK', member['nik'] ?? '-'),
          _profileItem(Icons.phone, 'Telepon', member['phone'] ?? '-'),
          _profileItem(Icons.location_on, 'Alamat', member['address'] ?? '-'),
          _profileItem(Icons.wc, 'Jenis Kelamin', member['gender'] == 'L' ? 'Laki-laki' : 'Perempuan'),
          _profileItem(Icons.work, 'Pekerjaan', member['occupation'] ?? '-'),
          _profileItem(Icons.calendar_today, 'Tanggal Bergabung', DateHelper.format(member['join_date'])),
        ],
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () async {
            await AuthService.logout();
            if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          },
          icon: const Icon(Icons.logout),
          label: const Text('Keluar'),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error, minimumSize: const Size(double.infinity, 50)),
        ),
      ],
    );
  }

  Widget _profileItem(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary)),
          Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
        ]),
      ]),
    );
  }
}
