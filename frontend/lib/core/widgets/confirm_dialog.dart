import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final Color? confirmColor;
  final IconData? icon;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Ya',
    this.cancelLabel = 'Batal',
    this.confirmColor,
    this.icon,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Ya',
    String cancelLabel = 'Batal',
    Color? confirmColor,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        confirmColor: confirmColor,
        icon: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: icon != null
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (confirmColor ?? AppColors.primary).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: confirmColor ?? AppColors.primary, size: 32),
            )
          : null,
      title: Text(title, textAlign: TextAlign.center),
      content: Text(message, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? AppColors.primary,
            minimumSize: const Size(100, 44),
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
