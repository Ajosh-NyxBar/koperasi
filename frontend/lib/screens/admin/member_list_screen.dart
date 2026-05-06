import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../services/api_service.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});
  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  List<dynamic> _members = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final result = await ApiService.get('/members');
      if (mounted) setState(() { _members = result['data']['data'] ?? []; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Anggota')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: Text('Tambah', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _members.isEmpty
              ? Center(child: Text('Belum ada anggota', style: GoogleFonts.poppins(color: AppTheme.textSecondary)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _members.length,
                    itemBuilder: (_, i) => _memberTile(_members[i]),
                  ),
                ),
    );
  }

  Widget _memberTile(Map<String, dynamic> m) {
    final name = m['full_name'] ?? '';
    final code = m['member_code'] ?? '';
    final status = m['status'] ?? 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppTheme.primaryColor))),
        title: Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(code, style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: status == 'active' ? AppTheme.success.withOpacity(0.1) : AppTheme.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20)),
          child: Text(status == 'active' ? 'Aktif' : 'Nonaktif',
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600,
              color: status == 'active' ? AppTheme.success : AppTheme.error)),
        ),
      ),
    );
  }

  void _showAddDialog() {
    final nameC = TextEditingController();
    final emailC = TextEditingController();
    final passC = TextEditingController();
    final nikC = TextEditingController();
    final phoneC = TextEditingController();
    String gender = 'L';

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Tambah Anggota', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.person))),
            const SizedBox(height: 12),
            TextField(controller: emailC, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
              keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            TextField(controller: passC, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)), obscureText: true),
            const SizedBox(height: 12),
            TextField(controller: nikC, decoration: const InputDecoration(labelText: 'NIK (16 digit)', prefixIcon: Icon(Icons.badge)),
              keyboardType: TextInputType.number, maxLength: 16),
            const SizedBox(height: 12),
            TextField(controller: phoneC, decoration: const InputDecoration(labelText: 'No. HP', prefixIcon: Icon(Icons.phone)),
              keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: gender,
              decoration: const InputDecoration(labelText: 'Jenis Kelamin', prefixIcon: Icon(Icons.wc)),
              items: const [DropdownMenuItem(value: 'L', child: Text('Laki-laki')), DropdownMenuItem(value: 'P', child: Text('Perempuan'))],
              onChanged: (v) => setS(() => gender = v ?? 'L'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (nameC.text.isEmpty || emailC.text.isEmpty || passC.text.isEmpty || nikC.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi semua field wajib')));
                  return;
                }
                try {
                  await ApiService.post('/members', {
                    'full_name': nameC.text, 'email': emailC.text, 'password': passC.text,
                    'nik': nikC.text, 'phone': phoneC.text, 'gender': gender,
                  });
                  if (mounted) Navigator.pop(ctx);
                  _load();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anggota berhasil ditambahkan'), backgroundColor: AppTheme.success));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error));
                }
              },
              child: const Text('Simpan'),
            ),
          ]),
        ),
      )),
    );
  }
}
