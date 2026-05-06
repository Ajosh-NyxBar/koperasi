class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.createdAt,
    this.readAt,
  });

  bool get isRead => readAt != null;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final notifData = json['data'] as Map<String, dynamic>? ?? {};
    return NotificationModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      title: notifData['title'] ?? json['title'] ?? '',
      body: notifData['body'] ?? json['body'] ?? '',
      data: notifData,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at']) : null,
    );
  }
}
