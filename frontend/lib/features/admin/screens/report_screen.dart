import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
                  hasDateFilter: false,
                  hasStatusFilter: true,
                  statusOptions: const ['active', 'inactive'],
                  statusLabels: const {'active': 'Aktif', 'inactive': 'Nonaktif'},
                  onDownload: ({String? from, String? to, String? status, required String format}) {
                    if (format == 'pdf') {
                      _download(() => svc.membersPdf(status: status));
                    } else {
                      _download(() => svc.membersExcel(status: status));
                    }
                  },
                ),
                const SizedBox(height: 12),
                _ReportSection(
                  title: 'Laporan Tabungan',
                  icon: Icons.savings_rounded,
                  color: AppColors.success,
                  hasDateFilter: true,
                  hasStatusFilter: false,
                  onDownload: ({String? from, String? to, String? status, required String format}) {
                    if (format == 'pdf') {
                      _download(() => svc.savingsPdf(from: from, to: to));
                    } else {
                      _download(() => svc.savingsExcel(from: from, to: to));
                    }
                  },
                ),
                const SizedBox(height: 12),
                _ReportSection(
                  title: 'Laporan Pembiayaan',
                  icon: Icons.trending_up_rounded,
                  color: AppColors.info,
                  hasDateFilter: true,
                  hasStatusFilter: true,
                  statusOptions: const ['pending', 'approved', 'completed', 'rejected'],
                  statusLabels: const {'pending': 'Pending', 'approved': 'Aktif', 'completed': 'Lunas', 'rejected': 'Ditolak'},
                  onDownload: ({String? from, String? to, String? status, required String format}) {
                    if (format == 'pdf') {
                      _download(() => svc.financingsPdf(status: status, from: from, to: to));
                    } else {
                      _download(() => svc.financingsExcel(status: status, from: from, to: to));
                    }
                  },
                ),
                const SizedBox(height: 12),
                _ReportSection(
                  title: 'Laporan Dana Sosial',
                  icon: Icons.volunteer_activism_rounded,
                  color: AppColors.secondary,
                  hasDateFilter: true,
                  hasStatusFilter: true,
                  statusOptions: const ['in', 'out'],
                  statusLabels: const {'in': 'Dana Masuk', 'out': 'Dana Keluar'},
                  statusFilterLabel: 'Arah',
                  onDownload: ({String? from, String? to, String? status, required String format}) {
                    if (format == 'pdf') {
                      _download(() => svc.socialFundsPdf(direction: status, from: from, to: to));
                    } else {
                      _download(() => svc.socialFundsExcel(direction: status, from: from, to: to));
                    }
                  },
                ),
              ],
            ),
    );
  }
}

class _ReportSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool hasDateFilter;
  final bool hasStatusFilter;
  final List<String>? statusOptions;
  final Map<String, String>? statusLabels;
  final String? statusFilterLabel;
  final void Function({String? from, String? to, String? status, required String format}) onDownload;

  const _ReportSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.hasDateFilter,
    required this.hasStatusFilter,
    this.statusOptions,
    this.statusLabels,
    this.statusFilterLabel,
    required this.onDownload,
  });

  @override
  State<_ReportSection> createState() => _ReportSectionState();
}

class _ReportSectionState extends State<_ReportSection> {
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _selectedStatus;
  bool _expanded = false;

  final _dateFormat = DateFormat('dd MMM yyyy');
  final _apiDateFormat = DateFormat('yyyy-MM-dd');

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? (_fromDate ?? now.subtract(const Duration(days: 30))) : (_toDate ?? now),
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: isFrom ? 'Pilih tanggal mulai' : 'Pilih tanggal akhir',
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  void _doDownload(String format) {
    widget.onDownload(
      from: _fromDate != null ? _apiDateFormat.format(_fromDate!) : null,
      to: _toDate != null ? _apiDateFormat.format(_toDate!) : null,
      status: _selectedStatus,
      format: format,
    );
  }

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
          // Header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: widget.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(widget.icon, color: widget.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(widget.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
              Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppColors.onSurfaceVariant),
            ]),
          ),

          // Filter section (expandable)
          if (_expanded) ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),

            // Date filter
            if (widget.hasDateFilter) ...[
              Text('Periode', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(isFrom: true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.outline),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Text(
                              _fromDate != null ? _dateFormat.format(_fromDate!) : 'Dari',
                              style: TextStyle(fontSize: 12, color: _fromDate != null ? null : AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('-')),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(isFrom: false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.outline),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Text(
                              _toDate != null ? _dateFormat.format(_toDate!) : 'Sampai',
                              style: TextStyle(fontSize: 12, color: _toDate != null ? null : AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_fromDate != null || _toDate != null) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => setState(() { _fromDate = null; _toDate = null; }),
                    child: Text('Reset tanggal', style: TextStyle(fontSize: 11, color: AppColors.error)),
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],

            // Status filter
            if (widget.hasStatusFilter && widget.statusOptions != null) ...[
              Text(widget.statusFilterLabel ?? 'Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Semua'),
                    selected: _selectedStatus == null,
                    onSelected: (_) => setState(() => _selectedStatus = null),
                    labelStyle: TextStyle(fontSize: 12, color: _selectedStatus == null ? Colors.white : null),
                    selectedColor: widget.color,
                  ),
                  ...widget.statusOptions!.map((s) => ChoiceChip(
                    label: Text(widget.statusLabels?[s] ?? s),
                    selected: _selectedStatus == s,
                    onSelected: (_) => setState(() => _selectedStatus = s),
                    labelStyle: TextStyle(fontSize: 12, color: _selectedStatus == s ? Colors.white : null),
                    selectedColor: widget.color,
                  )),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Preview info
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.info),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _buildPreviewText(),
                      style: TextStyle(fontSize: 11, color: AppColors.info),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Download buttons
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _doDownload('pdf'),
                icon: const Icon(Icons.picture_as_pdf, size: 18),
                label: const Text('PDF'),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _doDownload('excel'),
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

  String _buildPreviewText() {
    final parts = <String>[];
    if (_fromDate != null && _toDate != null) {
      parts.add('Periode: ${_dateFormat.format(_fromDate!)} - ${_dateFormat.format(_toDate!)}');
    } else if (_fromDate != null) {
      parts.add('Dari: ${_dateFormat.format(_fromDate!)}');
    } else if (_toDate != null) {
      parts.add('Sampai: ${_dateFormat.format(_toDate!)}');
    }
    if (_selectedStatus != null) {
      final label = widget.statusLabels?[_selectedStatus!] ?? _selectedStatus!;
      parts.add('${widget.statusFilterLabel ?? 'Status'}: $label');
    }
    if (parts.isEmpty) return 'Semua data akan ditampilkan (tanpa filter)';
    return parts.join(' | ');
  }
}
