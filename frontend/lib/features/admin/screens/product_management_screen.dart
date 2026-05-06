import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';

final _categoriesProvider = StateProvider<AsyncValue<List<CategoryModel>>>((ref) => const AsyncValue.loading());
final _productsProvider = StateProvider<AsyncValue<List<ProductModel>>>((ref) => const AsyncValue.loading());

class ProductManagementScreen extends ConsumerStatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  ConsumerState<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends ConsumerState<ProductManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    Future.microtask(_loadAll);
  }

  Future<void> _loadAll() async {
    final svc = ref.read(productServiceProvider);
    try {
      final cats = await svc.getCategories();
      ref.read(_categoriesProvider.notifier).state = AsyncValue.data(cats);
    } catch (e, st) {
      ref.read(_categoriesProvider.notifier).state = AsyncValue.error(e, st);
    }
    try {
      final prods = await svc.getProducts();
      ref.read(_productsProvider.notifier).state = AsyncValue.data(prods.items);
    } catch (e, st) {
      ref.read(_productsProvider.notifier).state = AsyncValue.error(e, st);
    }
  }

  void _showCategoryForm({CategoryModel? cat}) {
    final nameCtrl = TextEditingController(text: cat?.name ?? '');
    final descCtrl = TextEditingController(text: cat?.description ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cat != null ? 'Edit Kategori' : 'Tambah Kategori', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            AppTextField(label: 'Nama', controller: nameCtrl),
            const SizedBox(height: 12),
            AppTextField(label: 'Deskripsi', controller: descCtrl, maxLines: 2),
            const SizedBox(height: 20),
            AppButton(
              label: 'Simpan',
              onPressed: () async {
                try {
                  final svc = ref.read(productServiceProvider);
                  if (cat != null) {
                    await svc.updateCategory(cat.id, {'name': nameCtrl.text, 'description': descCtrl.text});
                  } else {
                    await svc.createCategory({'name': nameCtrl.text, 'description': descCtrl.text});
                  }
                  if (mounted) { Navigator.pop(ctx); _loadAll(); context.showSuccessSnack('Kategori disimpan'); }
                } on ApiException catch (e) {
                  if (mounted) context.showSnack(e.firstError, isError: true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showProductForm() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final buyCtrl = TextEditingController();
    final marginCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    int? selectedCatId;
    XFile? imageFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tambah Produk', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                AppTextField(label: 'Nama', controller: nameCtrl),
                const SizedBox(height: 12),
                AppTextField(label: 'Deskripsi', controller: descCtrl, maxLines: 2),
                const SizedBox(height: 12),
                Consumer(builder: (_, ref, __) {
                  final cats = ref.watch(_categoriesProvider);
                  return cats.when(
                    loading: () => const ShimmerLoading(height: 50),
                    error: (_, __) => const Text('Error'),
                    data: (list) => DropdownButtonFormField<int>(
                      value: selectedCatId,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: list.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                      onChanged: (v) => setSheetState(() => selectedCatId = v),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                AppTextField(label: 'Harga Beli', controller: buyCtrl, keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                AppTextField(label: 'Margin (%)', controller: marginCtrl, keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                AppTextField(label: 'Stok', controller: stockCtrl, keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800);
                    if (picked != null) setSheetState(() => imageFile = picked);
                  },
                  icon: const Icon(Icons.image),
                  label: Text(imageFile != null ? 'Gambar dipilih' : 'Pilih Gambar'),
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Simpan Produk',
                  onPressed: () async {
                    try {
                      final formData = FormData.fromMap({
                        'name': nameCtrl.text,
                        'description': descCtrl.text,
                        'category_id': selectedCatId,
                        'buy_price': double.tryParse(buyCtrl.text) ?? 0,
                        'margin_percent': double.tryParse(marginCtrl.text) ?? 0,
                        'stock': int.tryParse(stockCtrl.text) ?? 0,
                        if (imageFile != null) 'image': await MultipartFile.fromFile(imageFile!.path, filename: imageFile!.name),
                      });
                      await ref.read(productServiceProvider).createProduct(formData);
                      if (mounted) { Navigator.pop(ctx); _loadAll(); context.showSuccessSnack('Produk ditambahkan'); }
                    } on ApiException catch (e) {
                      if (mounted) context.showSnack(e.firstError, isError: true);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk & Kategori'),
        bottom: TabBar(controller: _tabCtrl, tabs: const [Tab(text: 'Kategori'), Tab(text: 'Produk')], indicatorColor: AppColors.primary, labelColor: AppColors.primary),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabCtrl.index == 0) _showCategoryForm();
          else _showProductForm();
        },
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // Categories tab
          RefreshIndicator(
            onRefresh: _loadAll,
            child: Consumer(builder: (_, ref, __) {
              final cats = ref.watch(_categoriesProvider);
              return cats.when(
                loading: () => const ShimmerList(),
                error: (e, _) => Center(child: Text('$e')),
                data: (list) => list.isEmpty
                    ? const EmptyState(icon: Icons.category_outlined, title: 'Belum ada kategori')
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final c = list[i];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.outline)),
                            child: Row(
                              children: [
                                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.category_rounded, color: AppColors.primary, size: 20)),
                                const SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  if (c.description != null) Text(c.description!, style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                                  Text('${c.productCount} produk', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                                ])),
                                IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _showCategoryForm(cat: c)),
                                IconButton(icon: const Icon(Icons.delete, size: 18, color: AppColors.error), onPressed: () async {
                                  final ok = await ConfirmDialog.show(context, title: 'Hapus', message: 'Hapus kategori ${c.name}?', confirmColor: AppColors.error, confirmLabel: 'Hapus');
                                  if (ok == true) { await ref.read(productServiceProvider).deleteCategory(c.id); _loadAll(); }
                                }),
                              ],
                            ),
                          );
                        },
                      ),
              );
            }),
          ),
          // Products tab
          RefreshIndicator(
            onRefresh: _loadAll,
            child: Consumer(builder: (_, ref, __) {
              final prods = ref.watch(_productsProvider);
              return prods.when(
                loading: () => const ShimmerList(),
                error: (e, _) => Center(child: Text('$e')),
                data: (list) => list.isEmpty
                    ? const EmptyState(icon: Icons.inventory_2_outlined, title: 'Belum ada produk')
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final p = list[i];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.outline)),
                            child: Row(
                              children: [
                                Container(
                                  width: 50, height: 50,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColors.surfaceVariant),
                                  child: p.imageUrl != null ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(p.imageUrl!, fit: BoxFit.cover)) : const Icon(Icons.image, color: AppColors.onSurfaceVariant),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text(p.sellingPrice.currency, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                                  Text('Stok: ${p.stock} • ${p.categoryName ?? ''}', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                                ])),
                                IconButton(icon: Icon(Icons.delete, size: 18, color: AppColors.error), onPressed: () async {
                                  final ok = await ConfirmDialog.show(context, title: 'Hapus', message: 'Hapus produk ${p.name}?', confirmColor: AppColors.error, confirmLabel: 'Hapus');
                                  if (ok == true) { await ref.read(productServiceProvider).deleteProduct(p.id); _loadAll(); }
                                }),
                              ],
                            ),
                          );
                        },
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
