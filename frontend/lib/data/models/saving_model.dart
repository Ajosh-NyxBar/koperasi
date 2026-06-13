import 'api_response.dart';

/// Hasil endpoint GET /savings/balance : saldo + riwayat transaksi (paginated).
class SavingBalance {
  final double balance;
  final PaginatedData<SavingTransaction> transactions;

  SavingBalance({required this.balance, required this.transactions});

  factory SavingBalance.fromJson(Map<String, dynamic> json) {
    final txJson = json['transactions'];
    return SavingBalance(
      balance: SavingTransaction._d(json['balance']),
      transactions: txJson is Map<String, dynamic>
          ? PaginatedData.fromJson(txJson, SavingTransaction.fromJson)
          : PaginatedData(items: const [], currentPage: 1, lastPage: 1, total: 0),
    );
  }
}

class SavingTransaction {
  final int id;
  final String type;
  final String typeLabel;
  final double amount;
  final double balanceAfter;
  final String? reference;
  final String? note;
  final DateTime transactionDate;
  final DateTime createdAt;

  SavingTransaction({
    required this.id,
    required this.type,
    required this.typeLabel,
    required this.amount,
    required this.balanceAfter,
    this.reference,
    this.note,
    required this.transactionDate,
    required this.createdAt,
  });

  bool get isDeposit => type == 'deposit';

  factory SavingTransaction.fromJson(Map<String, dynamic> json) {
    return SavingTransaction(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      typeLabel: json['type_label'] ?? (json['type'] == 'deposit' ? 'Setoran' : 'Penarikan'),
      amount: _d(json['amount']),
      balanceAfter: _d(json['balance_after']),
      reference: json['reference'],
      note: json['description'],
      transactionDate: DateTime.tryParse(json['transaction_date'] ?? '') ?? DateTime.now(),
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
  final String status;
  final DateTime? paidAt;
  final DateTime dueDate;

  MandatorySaving({
    required this.id,
    required this.period,
    required this.amount,
    required this.status,
    this.paidAt,
    required this.dueDate,
  });

  bool get isPaid => status == 'paid';
  bool get isOverdue => status == 'overdue';

  factory MandatorySaving.fromJson(Map<String, dynamic> json) {
    return MandatorySaving(
      id: json['id'] ?? 0,
      period: json['period'] ?? '',
      amount: SavingTransaction._d(json['amount']),
      status: json['status'] ?? 'unpaid',
      paidAt: json['paid_date'] != null ? DateTime.tryParse(json['paid_date']) : null,
      dueDate: DateTime.tryParse(json['due_date'] ?? '') ?? DateTime.now(),
    );
  }
}

class PrincipalSaving {
  final int id;
  final double amount;
  final String status;
  final DateTime? paidAt;

  PrincipalSaving({
    required this.id,
    required this.amount,
    required this.status,
    this.paidAt,
  });

  bool get isPaid => status == 'paid';

  factory PrincipalSaving.fromJson(Map<String, dynamic> json) {
    return PrincipalSaving(
      id: json['id'] ?? 0,
      amount: SavingTransaction._d(json['amount']),
      status: json['status'] ?? 'unpaid',
      paidAt: json['paid_date'] != null ? DateTime.tryParse(json['paid_date']) : null,
    );
  }
}
