class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? photoUrl;
  final String? token;
  final MemberInfo? member;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.photoUrl,
    this.token,
    this.member,
  });

  bool get isAdmin => role == 'admin';
  bool get isMember => role == 'member';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'member',
      photoUrl: json['photo_url'],
      token: json['token'],
      member: json['member'] != null
          ? MemberInfo.fromJson(json['member'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'photo_url': photoUrl,
        'token': token,
        'member': member?.toJson(),
      };
}

class MemberInfo {
  final int id;
  final String memberId;
  final String? address;
  final String? occupation;
  final DateTime? joinDate;

  MemberInfo({
    required this.id,
    required this.memberId,
    this.address,
    this.occupation,
    this.joinDate,
  });

  factory MemberInfo.fromJson(Map<String, dynamic> json) {
    return MemberInfo(
      id: json['id'] ?? 0,
      memberId: json['member_id'] ?? '',
      address: json['address'],
      occupation: json['occupation'],
      joinDate: json['join_date'] != null
          ? DateTime.tryParse(json['join_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'member_id': memberId,
        'address': address,
        'occupation': occupation,
        'join_date': joinDate?.toIso8601String(),
      };
}
