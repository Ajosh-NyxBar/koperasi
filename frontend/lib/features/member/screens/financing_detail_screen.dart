import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/financing_model.dart';
import '../../../data/services/financing_service.dart';

class FinancingDetailScreen extends ConsumerStatefulWidget {
  final int financingId;
  const FinancingDetailScreen({super.key, required this.financingId});

  @override
  ConsumerState<FinancingDetailScreen> createState() => _FinancingDetailScreenState();
}

class _FinancingDetailScreenState extends ConsumerState<FinancingDetailScreen> {
  FinancingModel? _financing;
  List<InstallmentModel>? _installments;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final svc = ref.read(financingServiceProvider);
      final f = await svc.getFinancing(widget.financingId);
      final inst = await svc.getInstallments(widget.financingId);
      setState(() { _financing = f; _installments = inst; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pembiayaan')),
      body: _loading
          ? const Padding(padding: EdgeInsets.all(16), child: ShimmerList(count: 4))
          : _financing == null
              ? const Center(child: Text('Data tidak ditemukan'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(_financing!.type.toUpperCase(), style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 12)),
                                  const Spacer(),
                                  StatusBadge.fromStatus(_financing!.status),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(_financing!.amount.currency, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              Text('${_financing!.tenor} bulan • ${_financing!.interestRate}%/thn', style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Info rows
                        _InfoRow('Cicilan/bulan', _financing!.monthlyPayment.currency),
                        _InfoRow('Total Bayar', _financing!.totalPayment.currency),
                        _InfoRow('Tujuan', _financing!.purpose ?? '-'),
                        _InfoRow('Jaminan', '${_financing!.guaranteeType ?? '-'} ${_financing!.guaranteeDetail ?? ''}'),
                        if (_financing!.rejectionReason != null)
                          _InfoRow('Alasan Ditolak', _financing!.rejectionReason!),
                        const SizedBox(height: 20),

                        // Installments
                        if (_installments != null && _installments!.isNotEmpty) ...[
                          Text('Jadwal Cicilan', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 12),
                          ...(_installments!.map((inst) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardTheme.color,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: inst.isOverdue ? AppColors.error.withOpacity(0.3) : AppColors.outline),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: (inst.isPaid ? AppColors.success : inst.isOverdue ? AppColors.error : AppColors.info).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text('${inst.installmentNumber}', style: TextStyle(fontWeight: FontWeight.w700, color: inst.isPaid ? AppColors.success : inst.isOverdue ? AppColors.error : AppColors.info)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(inst.amount.currency, style: const TextStyle(fontWeight: FontWeight.w600)),
                                          Text('Jatuh tempo: ${inst.dueDate.formatted}', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                                          if (inst.penalty > 0) Text('Denda: ${inst.penalty.currency}', style: const TextStyle(fontSize: 11, color: AppColors.error)),
                                        ],
                                      ),
                                    ),
                                    StatusBadge.fromStatus(inst.status),
                                  ],
                                ),
                              ))),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }
}
