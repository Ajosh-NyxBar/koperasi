import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/services/penalty_service.dart';

class PenaltyManagementScreen extends ConsumerStatefulWidget {
  const PenaltyManagementScreen({super.key});

  @override
  ConsumerState<PenaltyManagementScreen> createState() => _PenaltyManagementScreenState();
}

class _PenaltyManagementScreenState extends ConsumerState<PenaltyManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _overview;
  List<PenaltySettingModel>? _settings;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final svc = ref.read(penaltyServiceProvider);
      final results = await Future.wait([
        svc.getOverview(),
        svc.getSettings(),
      ]);
      setState(() {
        _overview = results[0] as Map<String, dynamic>;
        _settings = results[1] as List<PenaltySettingModel>;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Denda'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Pengaturan'),
            Tab(text: 'Keringanan'),
          ],
        ),
      ),
      body: _loading
          ? const Padding(padding: EdgeInsets.all(16), child: ShimmerList(count: 5))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildSettingsTab(),
                _buildWaiverTab(),
              ],
            ),
    );
  }

  // ==================== OVERVIEW TAB ====================

  Widget _buildOverviewTab() {
    if (_overview == null) return const EmptyState(icon: Icons.error_outline, title: 'Gagal memuat data');

    final summary = _overview!['summary'] as Map<String, dynamic>;
    final items = (_overview!['items'] as List?) ?? [];

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(child: _SummaryCard(
                title: 'Total Denda',
                value: (summary['total_current_penalty'] as num).toDouble().currency,
                color: AppColors.error,
                icon: Icons.money_off,
              )),
              const SizedBox(width: 10),
              Expanded(child: _SummaryCard(
                title: 'Sudah Dibayar',
                value: (summary['total_paid'] as num).toDouble().currency,
                color: AppColors.success,
                icon: Icons.check_circle,
              )),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _SummaryCard(
                title: 'Dibebaskan',
                value: (summary['total_waived'] as num).toDouble().currency,
                color: AppColors.info,
                icon: Icons.card_giftcard,
              )),
              const SizedBox(width: 10),
              Expanded(child: _SummaryCard(
                title: 'Cicilan Overdue',
                value: '${summary['overdue_count']}',
                color: AppColors.warning,
                icon: Icons.warning_amber,
              )),
            ],
          ),
          const SizedBox(height: 20),

          // List overdue installments
          Text('Daftar Cicilan Terlambat', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          if (items.isEmpty)
            const EmptyState(icon: Icons.celebration, title: 'Tidak ada cicilan terlambat')
          else
            ...items.map((item) => _OverdueItem(
              item: item,
              onWaive: () => _showWaiveDialog(item),
            )),
        ],
      ),
    );
  }

  // ==================== SETTINGS TAB ====================

  Widget _buildSettingsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Current default info
          if (_settings != null && _settings!.isNotEmpty) ...[
            ...(_settings!.map((s) => _SettingCard(
              setting: s,
              onEdit: () => _showSettingDialog(setting: s),
              onDelete: s.isDefault ? null : () => _deleteSetting(s),
              onSetDefault: s.isDefault ? null : () => _setDefault(s),
            ))),
          ] else
            const EmptyState(icon: Icons.settings, title: 'Belum ada pengaturan denda'),

          const SizedBox(height: 16),
          AppButton(
            label: 'Tambah Pengaturan',
            onPressed: () => _showSettingDialog(),
          ),
        ],
      ),
    );
  }

  // ==================== WAIVER TAB ====================

  Widget _buildWaiverTab() {
    return _WaiverHistoryTab(penaltyService: ref.read(penaltyServiceProvider));
  }

  // ==================== DIALOGS ====================

  void _showWaiveDialog(Map<String, dynamic> item) {
    final amountCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    final currentPenalty = (item['current_penalty'] as num).toDouble();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keringanan Denda'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Anggota: ${item['member_name']}'),
              Text('Kontrak: ${item['contract_number']}'),
              Text('Cicilan ke-${item['installment_number']}'),
              Text('Denda saat ini: ${currentPenalty.currency}', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Jumlah Keringanan (Rp)',
                hint: 'Maks ${currentPenalty.currency}',
                controller: amountCtrl,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Alasan',
                hint: 'Jelaskan alasan keringanan',
                controller: reasonCtrl,
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              final amount = double.tryParse(amountCtrl.text) ?? 0;
              if (amount <= 0 || amount > currentPenalty) {
                context.showSnack('Jumlah tidak valid', isError: true);
                return;
              }
              if (reasonCtrl.text.length < 5) {
                context.showSnack('Alasan minimal 5 karakter', isError: true);
                return;
              }

              try {
                await ref.read(penaltyServiceProvider).waivePenalty(
                  item['installment_id'],
                  amount: amount,
                  reason: reasonCtrl.text,
                );
                if (mounted) {
                  Navigator.pop(ctx);
                  context.showSuccessSnack('Keringanan berhasil diberikan');
                  _loadData();
                }
              } on ApiException catch (e) {
                if (mounted) context.showSnack(e.firstError, isError: true);
              }
            },
            child: const Text('Berikan Keringanan'),
          ),
        ],
      ),
    );
  }

  void _showSettingDialog({PenaltySettingModel? setting}) {
    final nameCtrl = TextEditingController(text: setting?.name ?? '');
    final penaltyCtrl = TextEditingController(text: setting?.penaltyPerDay.toStringAsFixed(0) ?? '5000');
    final graceCtrl = TextEditingController(text: setting?.gracePeriodDays.toString() ?? '0');
    final maxCtrl = TextEditingController(text: setting?.maxPenaltyPercentage.toStringAsFixed(0) ?? '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(setting == null ? 'Tambah Pengaturan' : 'Edit Pengaturan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(label: 'Nama', hint: 'e.g. Default, Ringan', controller: nameCtrl),
              const SizedBox(height: 12),
              AppTextField(label: 'Denda per Hari (Rp)', hint: '5000', controller: penaltyCtrl, keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              AppTextField(label: 'Grace Period (hari)', hint: '0 = tanpa toleransi', controller: graceCtrl, keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              AppTextField(label: 'Maks Denda (%)', hint: '0 = tanpa batas', controller: maxCtrl, keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              final data = {
                'name': nameCtrl.text,
                'penalty_per_day': double.tryParse(penaltyCtrl.text) ?? 5000,
                'grace_period_days': int.tryParse(graceCtrl.text) ?? 0,
                'max_penalty_percentage': double.tryParse(maxCtrl.text) ?? 0,
              };

              try {
                final svc = ref.read(penaltyServiceProvider);
                if (setting == null) {
                  await svc.createSetting(data);
                } else {
                  await svc.updateSetting(setting.id, data);
                }
                if (mounted) {
                  Navigator.pop(ctx);
                  context.showSuccessSnack('Pengaturan berhasil disimpan');
                  _loadData();
                }
              } on ApiException catch (e) {
                if (mounted) context.showSnack(e.firstError, isError: true);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSetting(PenaltySettingModel setting) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pengaturan'),
        content: Text('Yakin ingin menghapus "${setting.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(penaltyServiceProvider).deleteSetting(setting.id);
        if (mounted) {
          context.showSuccessSnack('Pengaturan berhasil dihapus');
          _loadData();
        }
      } on ApiException catch (e) {
        if (mounted) context.showSnack(e.firstError, isError: true);
      }
    }
  }

  Future<void> _setDefault(PenaltySettingModel setting) async {
    try {
      await ref.read(penaltyServiceProvider).updateSetting(setting.id, {'is_default': true});
      if (mounted) {
        context.showSuccessSnack('${setting.name} dijadikan default');
        _loadData();
      }
    } on ApiException catch (e) {
      if (mounted) context.showSnack(e.firstError, isError: true);
    }
  }
}

// ==================== WIDGETS ====================

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({required this.title, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: color)),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _OverdueItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onWaive;

  const _OverdueItem({required this.item, required this.onWaive});

  @override
  Widget build(BuildContext context) {
    final daysOverdue = item['days_overdue'] as int;
    final currentPenalty = (item['current_penalty'] as num).toDouble();
    final outstandingPenalty = (item['outstanding_penalty'] as num).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['member_name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('${item['contract_number']} • Cicilan ke-${item['installment_number']}', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$daysOverdue hari', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.error)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Denda: ${currentPenalty.currency}', style: TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600)),
                  if (outstandingPenalty != currentPenalty)
                    Text('Belum bayar: ${outstandingPenalty.currency}', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                ],
              )),
              TextButton.icon(
                onPressed: onWaive,
                icon: const Icon(Icons.card_giftcard, size: 16),
                label: const Text('Keringanan'),
                style: TextButton.styleFrom(foregroundColor: AppColors.info),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final PenaltySettingModel setting;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSetDefault;

  const _SettingCard({required this.setting, required this.onEdit, this.onDelete, this.onSetDefault});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: setting.isDefault ? AppColors.primary.withOpacity(0.3) : AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(setting.name, style: const TextStyle(fontWeight: FontWeight.w700))),
              if (setting.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text('Default', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Denda: Rp ${setting.penaltyPerDay.toStringAsFixed(0)}/hari', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
          Text('Grace period: ${setting.gracePeriodDays} hari', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
          Text('Maks denda: ${setting.maxPenaltyPercentage > 0 ? '${setting.maxPenaltyPercentage.toStringAsFixed(0)}% dari pokok' : 'Tanpa batas'}', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onSetDefault != null)
                TextButton(onPressed: onSetDefault, child: const Text('Jadikan Default', style: TextStyle(fontSize: 12))),
              TextButton(onPressed: onEdit, child: const Text('Edit', style: TextStyle(fontSize: 12))),
              if (onDelete != null)
                TextButton(
                  onPressed: onDelete,
                  child: Text('Hapus', style: TextStyle(fontSize: 12, color: AppColors.error)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaiverHistoryTab extends StatefulWidget {
  final PenaltyService penaltyService;
  const _WaiverHistoryTab({required this.penaltyService});

  @override
  State<_WaiverHistoryTab> createState() => _WaiverHistoryTabState();
}

class _WaiverHistoryTabState extends State<_WaiverHistoryTab> {
  List<dynamic>? _waivers;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final result = await widget.penaltyService.getWaiverHistory();
      setState(() {
        _waivers = (result['data'] as List?) ?? [];
        _loading = false;
      });
    } catch (_) {
      setState(() { _waivers = []; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Padding(padding: EdgeInsets.all(16), child: ShimmerList(count: 4));

    if (_waivers == null || _waivers!.isEmpty) {
      return const EmptyState(icon: Icons.history, title: 'Belum ada riwayat keringanan');
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _waivers!.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final w = _waivers![i] as Map<String, dynamic>;
          final waivedAmount = (w['waived_amount'] as num?)?.toDouble() ?? 0;
          final originalPenalty = (w['original_penalty'] as num?)?.toDouble() ?? 0;

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
                    Icon(Icons.card_giftcard, size: 16, color: AppColors.info),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Keringanan ${waivedAmount.currency}', style: const TextStyle(fontWeight: FontWeight.w600))),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Denda awal: ${originalPenalty.currency}', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                Text('Alasan: ${w['reason'] ?? '-'}', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                if (w['created_at'] != null)
                  Text(DateTime.tryParse(w['created_at'])?.formatted ?? '', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
              ],
            ),
          );
        },
      ),
    );
  }
}
