class SavingTransaction {
  final int id;
  final String type;
  final double amount;
  final double balanceAfter;
  final String? note;
  final String? cashierName;
  final DateTime createdAt;

  SavingTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    this.note,
    this.cashierName,
    required this.createdAt,
  });

  bool get isDeposit => type == 'deposit';

  factory SavingTransaction.fromJson(Map<String, dynamic> json) {
    return SavingTransaction(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      amount: _d(json['amount']),
      balanceAfter: _d(json['balance_after']),
      note: json['note'],
      cashierName: json['cashier_name'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  static double _d(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}

class MandatorySaving {
  final int id;
  final String period;
  final double amount;
  final bool isPaid;
  final DateTime? paidAt;
  final DateTime dueDate;

  MandatorySaving({
    required this.id,
    required this.period,
    required this.amount,
    required this.isPaid,
    this.paidAt,
    required this.dueDate,
  });

  factory MandatorySaving.fromJson(Map<String, dynamic> json) {
    return MandatorySaving(
      id: json['id'] ?? 0,
      period: json['period'] ?? '',
      amount: SavingTransaction._d(json['amount']),
      isPaid: json['is_paid'] ?? false,
      paidAt: json['paid_at'] != null ? DateTime.tryParse(json['paid_at']) : null,
      dueDate: DateTime.tryParse(json['due_date'] ?? '') ?? DateTime.now(),
    );
  }
}

class PrincipalSaving {
  final int id;
  final double amount;
  final DateTime paidAt;

  PrincipalSaving({
    required this.id,
    required this.amount,
    required this.paidAt,
  });

  factory PrincipalSaving.fromJson(Map<String, dynamic> json) {
    return PrincipalSaving(
      id: json['id'] ?? 0,
      amount: SavingTransaction._d(json['amount']),
      paidAt: DateTime.tryParse(json['paid_at'] ?? '') ?? DateTime.now(),
    );
  }
}
