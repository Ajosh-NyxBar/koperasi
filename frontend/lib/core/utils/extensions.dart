import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension StringExt on String {
  String get capitalize => isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
}

extension NumExt on num {
  String get currency => NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(this);

  String get compact => NumberFormat.compact(locale: 'id_ID').format(this);
}

extension DateTimeExt on DateTime {
  String get formatted => DateFormat('dd MMM yyyy', 'id_ID').format(this);
  String get fullFormatted => DateFormat('dd MMMM yyyy', 'id_ID').format(this);
  String get withTime => DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(this);
  String get monthYear => DateFormat('MMMM yyyy', 'id_ID').format(this);
  String get dayMonth => DateFormat('dd MMM', 'id_ID').format(this);
  String get timeOnly => DateFormat('HH:mm', 'id_ID').format(this);

  String get relative {
    final now = DateTime.now();
    final diff = now.difference(this);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return formatted;
  }
}

extension ContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : null,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showSuccessSnack(String message) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }
}
