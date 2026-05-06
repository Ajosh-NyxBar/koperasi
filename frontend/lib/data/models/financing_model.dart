class FinancingModel {
  final int id;
  final int memberId;
  final String? memberName;
  final String type;
  final double amount;
  final int tenor;
  final double interestRate;
  final double totalPayment;
  final double monthlyPayment;
  final String status;
  final String? purpose;
  final String? rejectionReason;
  final String? guaranteeType;
  final String? guaranteeDetail;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final double? progress;
  final List<InstallmentModel>? installments;

  FinancingModel({
    required this.id,
    required this.memberId,
    this.memberName,
    required this.type,
    required this.amount,
    required this.tenor,
    required this.interestRate,
    required this.totalPayment,
    required this.monthlyPayment,
    required this.status,
    this.purpose,
    this.rejectionReason,
    this.guaranteeType,
    this.guaranteeDetail,
    this.approvedAt,
    required this.createdAt,
    this.progress,
    this.installments,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isCompleted => status == 'completed';

  factory FinancingModel.fromJson(Map<String, dynamic> json) {
    return FinancingModel(
      id: json['id'] ?? 0,
      memberId: json['member_id'] ?? 0,
      memberName: json['member_name'] ?? json['member']?['name'],
      type: json['type'] ?? '',
      amount: _d(json['amount']),
      tenor: json['tenor'] ?? 0,
      interestRate: _d(json['interest_rate']),
      totalPayment: _d(json['total_payment']),
      monthlyPayment: _d(json['monthly_payment']),
      status: json['status'] ?? '',
      purpose: json['purpose'],
      rejectionReason: json['rejection_reason'],
      guaranteeType: json['guarantee_type'],
      guaranteeDetail: json['guarantee_detail'],
      approvedAt: json['approved_at'] != null
          ? DateTime.tryParse(json['approved_at'])
          : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      progress: _d(json['progress']),
      installments: json['installments'] != null
          ? (json['installments'] as List)
              .map((e) => InstallmentModel.fromJson(e))
              .toList()
          : null,
    );
  }

  static double _d(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}

class InstallmentModel {
  final int id;
  final int installmentNumber;
  final double amount;
  final double principal;
  final double interest;
  final double penalty;
  final String status;
  final DateTime dueDate;
  final DateTime? paidAt;
  final double? paidAmount;

  InstallmentModel({
    required this.id,
    required this.installmentNumber,
    required this.amount,
    required this.principal,
    required this.interest,
    required this.penalty,
    required this.status,
    required this.dueDate,
    this.paidAt,
    this.paidAmount,
  });

  bool get isPaid => status == 'paid';
  bool get isOverdue => status == 'overdue';

  factory InstallmentModel.fromJson(Map<String, dynamic> json) {
    return InstallmentModel(
      id: json['id'] ?? 0,
      installmentNumber: json['installment_number'] ?? 0,
      amount: FinancingModel._d(json['amount']),
      principal: FinancingModel._d(json['principal']),
      interest: FinancingModel._d(json['interest']),
      penalty: FinancingModel._d(json['penalty']),
      status: json['status'] ?? '',
      dueDate: DateTime.tryParse(json['due_date'] ?? '') ?? DateTime.now(),
      paidAt: json['paid_at'] != null ? DateTime.tryParse(json['paid_at']) : null,
      paidAmount: json['paid_amount'] != null ? FinancingModel._d(json['paid_amount']) : null,
    );
  }
}

class SimulationResult {
  final double amount;
  final int tenor;
  final double interestRate;
  final double monthlyPayment;
  final double totalPayment;
  final double totalInterest;
  final List<SimulationInstallment> schedule;

  SimulationResult({
    required this.amount,
    required this.tenor,
    required this.interestRate,
    required this.monthlyPayment,
    required this.totalPayment,
    required this.totalInterest,
    required this.schedule,
  });

  factory SimulationResult.fromJson(Map<String, dynamic> json) {
    return SimulationResult(
      amount: FinancingModel._d(json['amount']),
      tenor: json['tenor'] ?? 0,
      interestRate: FinancingModel._d(json['interest_rate']),
      monthlyPayment: FinancingModel._d(json['monthly_payment']),
      totalPayment: FinancingModel._d(json['total_payment']),
      totalInterest: FinancingModel._d(json['total_interest']),
      schedule: (json['schedule'] as List?)
              ?.map((e) => SimulationInstallment.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class SimulationInstallment {
  final int number;
  final double principal;
  final double interest;
  final double total;
  final double remainingBalance;

  SimulationInstallment({
    required this.number,
    required this.principal,
    required this.interest,
    required this.total,
    required this.remainingBalance,
  });

  factory SimulationInstallment.fromJson(Map<String, dynamic> json) {
    return SimulationInstallment(
      number: json['number'] ?? 0,
      principal: FinancingModel._d(json['principal']),
      interest: FinancingModel._d(json['interest']),
      total: FinancingModel._d(json['total']),
      remainingBalance: FinancingModel._d(json['remaining_balance']),
    );
  }
}
