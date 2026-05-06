import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/services/report_service.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  bool _downloading = false;

  Future<void> _download(Future<String> Function() fn) async {
    setState(() => _downloading = true);
    try {
      final path = await fn();
      if (mounted) {
        context.showSuccessSnack('File berhasil diunduh');
        OpenFilex.open(path);
      }
    } on ApiException catch (e) {
      if (mounted) context.showSnack(e.firstError, isError: true);
    } catch (e) {
      if (mounted) context.showSnack('Gagal mengunduh file', isError: true);
    }
    setState(() => _downloading = false);
  }

  @override
  Widget build(BuildContext context) {
    final svc = ref.read(reportServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan')),
      body: _downloading
          ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Mengunduh laporan...'),
            ]))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ReportSection(
                  title: 'Laporan Anggota',
                  icon: Icons.people_rounded,
                  color: AppColors.primary,
                  onPdf: () => _download(() => svc.membersPdf()),
                  onExcel: () => _download(() => svc.membersExcel()),
                ),
                const SizedBox(height: 12),
                _ReportSection(
                  title: 'Laporan Tabungan',
                  icon: Icons.savings_rounded,
                  color: AppColors.success,
                  onPdf: () => _download(() => svc.savingsPdf()),
                  onExcel: () => _download(() => svc.savingsExcel()),
                ),
                const SizedBox(height: 12),
                _ReportSection(
                  title: 'Laporan Pembiayaan',
                  icon: Icons.trending_up_rounded,
                  color: AppColors.info,
                  onPdf: () => _download(() => svc.financingsPdf()),
                  onExcel: () => _download(() => svc.financingsExcel()),
                ),
                const SizedBox(height: 12),
                _ReportSection(
                  title: 'Laporan Dana Sosial',
                  icon: Icons.volunteer_activism_rounded,
                  color: AppColors.secondary,
                  onPdf: () => _download(() => svc.socialFundsPdf()),
                  onExcel: () => _download(() => svc.socialFundsExcel()),
                ),
              ],
            ),
    );
  }
}

class _ReportSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onPdf;
  final VoidCallback onExcel;

  const _ReportSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.onPdf,
    required this.onExcel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPdf,
                icon: const Icon(Icons.picture_as_pdf, size: 18),
                label: const Text('PDF'),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onExcel,
                icon: const Icon(Icons.table_chart, size: 18),
                label: const Text('Excel'),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.success, side: const BorderSide(color: AppColors.success)),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
