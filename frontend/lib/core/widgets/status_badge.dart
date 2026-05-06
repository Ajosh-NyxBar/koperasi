import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = StatusType.info,
  });

  factory StatusBadge.fromStatus(String status) {
    final lower = status.toLowerCase();
    StatusType type;
    switch (lower) {
      case 'active' || 'aktif' || 'approved' || 'disetujui' || 'paid' || 'lunas' || 'completed':
        type = StatusType.success;
      case 'pending' || 'menunggu' || 'review':
        type = StatusType.warning;
      case 'rejected' || 'ditolak' || 'overdue' || 'jatuh_tempo' || 'inactive':
        type = StatusType.error;
      default:
        type = StatusType.info;
    }
    return StatusBadge(label: status.replaceAll('_', ' '), type: type);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: _fgColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color get _bgColor {
    switch (type) {
      case StatusType.success:
        return AppColors.successLight;
      case StatusType.warning:
        return AppColors.warningLight;
      case StatusType.error:
        return AppColors.errorLight;
      case StatusType.info:
        return AppColors.infoLight;
    }
  }

  Color get _fgColor {
    switch (type) {
      case StatusType.success:
        return AppColors.success;
      case StatusType.warning:
        return AppColors.warning;
      case StatusType.error:
        return AppColors.error;
      case StatusType.info:
        return AppColors.info;
    }
  }
}

enum StatusType { success, warning, error, info }
