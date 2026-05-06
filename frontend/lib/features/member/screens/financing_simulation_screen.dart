import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../providers/financing_provider.dart';

class FinancingSimulationScreen extends ConsumerStatefulWidget {
  const FinancingSimulationScreen({super.key});

  @override
  ConsumerState<FinancingSimulationScreen> createState() => _FinancingSimulationScreenState();
}

class _FinancingSimulationScreenState extends ConsumerState<FinancingSimulationScreen> {
  final _amountCtrl = TextEditingController();
  final _tenorCtrl = TextEditingController();
  String _type = 'murabahah';

  @override
  void dispose() {
    _amountCtrl.dispose();
    _tenorCtrl.dispose();
    super.dispose();
  }

  void _simulate() {
    if (_amountCtrl.text.isEmpty || _tenorCtrl.text.isEmpty) return;
    ref.read(simulationProvider.notifier).simulate({
      'amount': double.tryParse(_amountCtrl.text) ?? 0,
      'tenor': int.tryParse(_tenorCtrl.text) ?? 0,
      'type': _type,
    });
  }

  @override
  Widget build(BuildContext context) {
    final sim = ref.watch(simulationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Simulasi Pembiayaan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Jenis Pembiayaan'),
              items: const [
                DropdownMenuItem(value: 'murabahah', child: Text('Murabahah')),
                DropdownMenuItem(value: 'mudharabah', child: Text('Mudharabah')),
                DropdownMenuItem(value: 'musyarakah', child: Text('Musyarakah')),
              ],
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Jumlah Pembiayaan',
              hint: 'Masukkan jumlah',
              controller: _amountCtrl,
              prefixIcon: Icons.attach_money,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Tenor (bulan)',
              hint: 'Masukkan tenor',
              controller: _tenorCtrl,
              prefixIcon: Icons.calendar_month,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Hitung Simulasi',
              onPressed: _simulate,
              isLoading: sim.isLoading,
              icon: Icons.calculate_rounded,
            ),
            const SizedBox(height: 24),
            sim.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('$e', style: const TextStyle(color: AppColors.error)),
              data: (result) {
                if (result == null) return const SizedBox();
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hasil Simulasi', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const Divider(height: 24),
                      _SimRow('Jumlah', result.amount.currency),
                      _SimRow('Tenor', '${result.tenor} bulan'),
                      _SimRow('Margin/Bunga', '${result.interestRate}%'),
                      _SimRow('Cicilan/bulan', result.monthlyPayment.currency),
                      _SimRow('Total Bayar', result.totalPayment.currency),
                      _SimRow('Total Margin', result.totalInterest.currency),
                      if (result.schedule.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text('Jadwal Angsuran', style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        ...result.schedule.map((s) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  SizedBox(width: 30, child: Text('#${s.number}', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12))),
                                  Expanded(child: Text('Pokok: ${s.principal.currency}', style: const TextStyle(fontSize: 12))),
                                  Text(s.total.currency, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                ],
                              ),
                            )),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SimRow extends StatelessWidget {
  final String label;
  final String value;
  const _SimRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
