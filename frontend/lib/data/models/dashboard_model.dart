class AdminDashboard {
  final int totalMembers;
  final int activeMembers;
  final double totalSavings;
  final double totalFinancings;
  final int pendingFinancings;
  final double totalSocialFund;
  final int pendingApplications;
  final List<MonthlyStat> monthlyStats;

  AdminDashboard({
    required this.totalMembers,
    required this.activeMembers,
    required this.totalSavings,
    required this.totalFinancings,
    required this.pendingFinancings,
    required this.totalSocialFund,
    required this.pendingApplications,
    required this.monthlyStats,
  });

  factory AdminDashboard.fromJson(Map<String, dynamic> json) {
    return AdminDashboard(
      totalMembers: json['total_members'] ?? 0,
      // Backend hanya mengirim total anggota aktif (Member::active()).
      activeMembers: json['total_members'] ?? 0,
      totalSavings: _d(json['total_savings']),
      totalFinancings: _d(json['total_financing_amount']),
      pendingFinancings: json['pending_financing'] ?? 0,
      totalSocialFund: _d(json['social_fund_balance']),
      // Backend belum mengirim jumlah pengajuan bantuan pending di dashboard.
      pendingApplications: json['pending_applications'] ?? 0,
      monthlyStats: (json['monthly_stats'] as List?)
              ?.map((e) => MonthlyStat.fromJson(e))
              .toList() ??
          [],
    );
  }

  static double _d(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}

class MemberDashboard {
  final double savingBalance;
  final double principalSaving;
  final double totalFinancing;
  final int activeInstallments;
  final double nextInstallmentAmount;
  final DateTime? nextInstallmentDue;
  final int unpaidMandatory;
  final int unreadNotifications;
  final List<RecentTransaction> recentTransactions;

  MemberDashboard({
    required this.savingBalance,
    required this.principalSaving,
    required this.totalFinancing,
    required this.activeInstallments,
    required this.nextInstallmentAmount,
    this.nextInstallmentDue,
    required this.unpaidMandatory,
    required this.unreadNotifications,
    required this.recentTransactions,
  });

  factory MemberDashboard.fromJson(Map<String, dynamic> json) {
    return MemberDashboard(
      savingBalance: AdminDashboard._d(json['saving_balance']),
      principalSaving: AdminDashboard._d(json['principal_saving']),
      totalFinancing: AdminDashboard._d(json['total_financing']),
      activeInstallments: json['active_installments'] ?? 0,
      nextInstallmentAmount: AdminDashboard._d(json['next_installment_amount']),
      nextInstallmentDue: json['next_installment_due'] != null
          ? DateTime.tryParse(json['next_installment_due'])
          : null,
      unpaidMandatory: json['unpaid_mandatory'] ?? 0,
      unreadNotifications: json['unread_notifications'] ?? 0,
      recentTransactions: (json['recent_transactions'] as List?)
              ?.map((e) => RecentTransaction.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class MonthlyStat {
  final String month;
  final double savings;
  final double financings;

  MonthlyStat({required this.month, required this.savings, required this.financings});

  factory MonthlyStat.fromJson(Map<String, dynamic> json) {
    return MonthlyStat(
      month: json['label'] ?? json['period'] ?? '',
      savings: AdminDashboard._d(json['mandatory_savings']),
      financings: AdminDashboard._d(json['installment_income']),
    );
  }
}

class RecentTransaction {
  final String type;
  final String description;
  final double amount;
  final DateTime date;

  RecentTransaction({
    required this.type,
    required this.description,
    required this.amount,
    required this.date,
  });

  factory RecentTransaction.fromJson(Map<String, dynamic> json) {
    return RecentTransaction(
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      amount: AdminDashboard._d(json['amount']),
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    );
  }
}
