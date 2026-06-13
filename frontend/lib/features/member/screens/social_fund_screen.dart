import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/models/social_fund_model.dart';
import '../../../data/services/social_fund_service.dart';

final _appsProvider = StateProvider<AsyncValue<List<SocialFundApplication>>>((ref) => const AsyncValue.loading());

class SocialFundScreen extends ConsumerStatefulWidget {
  const SocialFundScreen({super.key});

  @override
  ConsumerState<SocialFundScreen> createState() => _SocialFundScreenState();
}

class _SocialFundScreenState extends ConsumerState<SocialFundScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    try {
      final result = await ref.read(socialFundServiceProvider).getApplications();
      ref.read(_appsProvider.notifier).state = AsyncValue.data(result.items);
    } catch (e, st) {
      ref.read(_appsProvider.notifier).state = AsyncValue.error(e, st);
    }
  }

  static const _typeOptions = [
    {'value': 'bantuan_sakit', 'label': 'Bantuan Sakit'},
    {'value': 'bantuan_pendidikan', 'label': 'Bantuan Pendidikan'},
    {'value': 'kegiatan_sosial', 'label': 'Kegiatan Sosial'},
    {'value': 'lainnya', 'label': 'Lainnya'},
  ];

  void _showApplySheet() {
    final reasonCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String? selectedType;
    File? selectedFile;
    String? selectedFileName;

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
                Text('Ajukan Bantuan', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),

                // Dropdown tipe bantuan
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Jenis Bantuan',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  items: _typeOptions.map((opt) => DropdownMenuItem(
                    value: opt['value'],
                    child: Text(opt['label']!),
                  )).toList(),
                  onChanged: (val) => setSheetState(() => selectedType = val),
                  hint: const Text('Pilih jenis bantuan'),
                ),
                const SizedBox(height: 12),

                AppTextField(label: 'Alasan', hint: 'Jelaskan alasan bantuan (min. 10 karakter)', controller: reasonCtrl, maxLines: 3),
                const SizedBox(height: 12),
                AppTextField(label: 'Jumlah (Rp)', hint: 'Minimal Rp 10.000', controller: amountCtrl, keyboardType: TextInputType.number),
                const SizedBox(height: 12),

                // Upload attachment
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lampiran (opsional)', style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                            );
                            if (result != null && result.files.single.path != null) {
                              setSheetState(() {
                                selectedFile = File(result.files.single.path!);
                                selectedFileName = result.files.single.name;
                              });
                            }
                          },
                          icon: const Icon(Icons.attach_file, size: 18),
                          label: const Text('Pilih File'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final picker = ImagePicker();
                            final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                            if (image != null) {
                              setSheetState(() {
                                selectedFile = File(image.path);
                                selectedFileName = image.name;
                              });
                            }
                          },
                          icon: const Icon(Icons.camera_alt, size: 18),
                          label: const Text('Kamera'),
                        ),
                      ],
                    ),
                    if (selectedFileName != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                          const SizedBox(width: 6),
                          Expanded(child: Text(selectedFileName!, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                          InkWell(
                            onTap: () => setSheetState(() { selectedFile = null; selectedFileName = null; }),
                            child: const Icon(Icons.close, size: 16, color: AppColors.error),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),

                AppButton(
                  label: 'Kirim Pengajuan',
                  onPressed: () async {
                    // Validasi
                    if (selectedType == null) {
                      context.showSnack('Pilih jenis bantuan', isError: true);
                      return;
                    }
                    if (reasonCtrl.text.length < 10) {
                      context.showSnack('Alasan minimal 10 karakter', isError: true);
                      return;
                    }
                    final amount = double.tryParse(amountCtrl.text) ?? 0;
                    if (amount < 10000) {
                      context.showSnack('Jumlah minimal Rp 10.000', isError: true);
                      return;
                    }

                    try {
                      final formMap = <String, dynamic>{
                        'type': selectedType,
                        'reason': reasonCtrl.text,
                        'requested_amount': amount,
                      };

                      if (selectedFile != null) {
                        formMap['attachment'] = await MultipartFile.fromFile(
                          selectedFile!.path,
                          filename: selectedFileName,
                        );
                      }

                      await ref.read(socialFundServiceProvider).applyForAid(FormData.fromMap(formMap));
                      if (mounted) {
                        Navigator.pop(ctx);
                        context.showSuccessSnack('Pengajuan berhasil dikirim');
                        _load();
                      }
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
  Widget build(BuildContext context) {
    final apps = ref.watch(_appsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dana Sosial')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showApplySheet,
        icon: const Icon(Icons.add),
        label: const Text('Ajukan'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: apps.when(
          loading: () => const ShimmerList(),
          error: (e, _) => Center(child: Text('$e')),
          data: (items) {
            if (items.isEmpty) return const EmptyState(icon: Icons.volunteer_activism_rounded, title: 'Belum ada pengajuan');
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final app = items[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(app.typeLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                          ),
                          const Spacer(),
                          StatusBadge.fromStatus(app.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(app.reason, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Text(app.amount.currency, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      if (app.approvedAmount != null && app.approvedAmount! > 0) ...[
                        Text('Disetujui: ${app.approvedAmount!.currency}', style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600)),
                      ],
                      Text(app.createdAt.formatted, style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                      if (app.attachmentUrl != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.attach_file, size: 14, color: AppColors.info),
                            const SizedBox(width: 4),
                            Text('Lampiran tersedia', style: TextStyle(fontSize: 11, color: AppColors.info)),
                          ],
                        ),
                      ],
                      if (app.adminNote != null) ...[
                        const SizedBox(height: 4),
                        Text('Admin: ${app.adminNote}', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, fontStyle: FontStyle.italic)),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
