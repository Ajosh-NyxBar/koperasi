import 'package:intl/intl.dart';

class CurrencyHelper {
  static final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String format(dynamic amount) {
    if (amount == null) return 'Rp 0';
    double value = 0;
    if (amount is String) {
      value = double.tryParse(amount) ?? 0;
    } else if (amount is int) {
      value = amount.toDouble();
    } else if (amount is double) {
      value = amount;
    }
    return _formatter.format(value);
  }

  static String formatCompact(dynamic amount) {
    double value = 0;
    if (amount is String) value = double.tryParse(amount) ?? 0;
    if (amount is int) value = amount.toDouble();
    if (amount is double) value = amount;

    if (value >= 1000000000) return 'Rp ${(value / 1000000000).toStringAsFixed(1)}M';
    if (value >= 1000000) return 'Rp ${(value / 1000000).toStringAsFixed(1)}Jt';
    if (value >= 1000) return 'Rp ${(value / 1000).toStringAsFixed(0)}Rb';
    return format(value);
  }
}

class DateHelper {
  static String format(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy', 'id').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  static String formatMonthYear(String? period) {
    if (period == null) return '-';
    try {
      final parts = period.split('-');
      final date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
      return DateFormat('MMMM yyyy', 'id').format(date);
    } catch (_) {
      return period;
    }
  }
}
