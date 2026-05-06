import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../services/api_service.dart';
import '../../utils/helpers.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<dynamic> _products = [];
  List<dynamic> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final pResult = await ApiService.get('/products');
      final cResult = await ApiService.get('/categories');
      if (mounted) setState(() {
        _products = pResult['data']['data'] ?? [];
        _categories = cResult['data'] ?? [];
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Katalog Produk')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProduct(),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Produk', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _products.length,
                itemBuilder: (_, i) => _productCard(_products[i]),
              ),
            ),
    );
  }

  Widget _productCard(Map<String, dynamic> p) {
    final basePrice = double.tryParse('${p['base_price']}') ?? 0;
    final margin = double.tryParse('${p['margin_percentage']}') ?? 0;
    final sellingPrice = basePrice + (basePrice * margin / 100);
    final catName = p['category']?['name'] ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.inventory_2, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p['name'] ?? '', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
          Text(catName, style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          Row(children: [
            Text(CurrencyHelper.format(sellingPrice), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
            const SizedBox(width: 8),
            Text('+${margin.toStringAsFixed(0)}%', style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.warning, fontWeight: FontWeight.w600)),
          ]),
        ])),
      ]),
    );
  }

  void _showAddProduct() {
    final nameC = TextEditingController();
    final priceC = TextEditingController();
    final marginC = TextEditingController(text: '10');
    final descC = TextEditingController();
    int? selectedCat = _categories.isNotEmpty ? _categories[0]['id'] : null;

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Tambah Produk', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: selectedCat,
              decoration: const InputDecoration(labelText: 'Kategori', prefixIcon: Icon(Icons.category)),
              items: _categories.map<DropdownMenuItem<int>>((c) => DropdownMenuItem(value: c['id'] as int, child: Text(c['name'] ?? ''))).toList(),
              onChanged: (v) => setS(() => selectedCat = v),
            ),
            const SizedBox(height: 12),
            TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Nama Produk', prefixIcon: Icon(Icons.label))),
            const SizedBox(height: 12),
            TextField(controller: priceC, decoration: const InputDecoration(labelText: 'Harga Dasar (Rp)', prefixIcon: Icon(Icons.money)),
              keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: marginC, decoration: const InputDecoration(labelText: 'Margin (%)', prefixIcon: Icon(Icons.percent)),
              keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: descC, decoration: const InputDecoration(labelText: 'Deskripsi', prefixIcon: Icon(Icons.description)),
              maxLines: 2),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ApiService.post('/products', {
                    'category_id': selectedCat, 'name': nameC.text,
                    'base_price': double.tryParse(priceC.text) ?? 0,
                    'margin_percentage': double.tryParse(marginC.text) ?? 10,
                    'description': descC.text,
                  });
                  if (mounted) Navigator.pop(ctx);
                  _load();
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
