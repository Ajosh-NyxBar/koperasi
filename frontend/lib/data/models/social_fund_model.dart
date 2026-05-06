class SocialFundModel {
  final int id;
  final int memberId;
  final String? memberName;
  final String type;
  final double amount;
  final String? note;
  final DateTime createdAt;

  SocialFundModel({
    required this.id,
    required this.memberId,
    this.memberName,
    required this.type,
    required this.amount,
    this.note,
    required this.createdAt,
  });

  bool get isContribution => type == 'contribution';

  factory SocialFundModel.fromJson(Map<String, dynamic> json) {
    return SocialFundModel(
      id: json['id'] ?? 0,
      memberId: json['member_id'] ?? 0,
      memberName: json['member_name'],
      type: json['type'] ?? '',
      amount: _d(json['amount']),
      note: json['note'],
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

class SocialFundApplication {
  final int id;
  final int memberId;
  final String? memberName;
  final String reason;
  final double amount;
  final String status;
  final String? attachmentUrl;
  final String? adminNote;
  final DateTime createdAt;
  final DateTime? decidedAt;

  SocialFundApplication({
    required this.id,
    required this.memberId,
    this.memberName,
    required this.reason,
    required this.amount,
    required this.status,
    this.attachmentUrl,
    this.adminNote,
    required this.createdAt,
    this.decidedAt,
  });

  bool get isPending => status == 'pending';

  factory SocialFundApplication.fromJson(Map<String, dynamic> json) {
    return SocialFundApplication(
      id: json['id'] ?? 0,
      memberId: json['member_id'] ?? 0,
      memberName: json['member_name'],
      reason: json['reason'] ?? '',
      amount: SocialFundModel._d(json['amount']),
      status: json['status'] ?? '',
      attachmentUrl: json['attachment_url'],
      adminNote: json['admin_note'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      decidedAt: json['decided_at'] != null
          ? DateTime.tryParse(json['decided_at'])
          : null,
    );
  }
}
