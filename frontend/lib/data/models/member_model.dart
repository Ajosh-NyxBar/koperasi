class MemberModel {
  final int id;
  final String memberId;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? occupation;
  final String? photoUrl;
  final DateTime? joinDate;
  final bool isActive;
  final double? savingBalance;
  final double? principalSaving;

  MemberModel({
    required this.id,
    required this.memberId,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.occupation,
    this.photoUrl,
    this.joinDate,
    this.isActive = true,
    this.savingBalance,
    this.principalSaving,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] ?? 0,
      memberId: json['member_code'] ?? '',
      name: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'],
      occupation: json['occupation'],
      photoUrl: json['photo_url'],
      joinDate: json['join_date'] != null
          ? DateTime.tryParse(json['join_date'])
          : null,
      isActive: (json['status'] ?? 'active') == 'active',
      savingBalance: _toDouble(json['saving_balance']),
      principalSaving: _toDouble(json['principal_saving']),
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'member_id': memberId,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'occupation': occupation,
        'join_date': joinDate?.toIso8601String(),
      };
}
