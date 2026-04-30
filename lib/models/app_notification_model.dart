class AppNotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final String targetRole;
  final String? targetUser;
  final String? orderId;
  final DateTime created;
  final bool isRead; 

  AppNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.targetRole,
    this.targetUser,
    this.orderId,
    required this.created,
    required this.isRead,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? '',
      targetRole: json['targetRole'] ?? '',
      targetUser: json['targetUser']?.toString(),
      orderId: json['orderId']?.toString(),
      created: DateTime.tryParse(json['created'] ?? '') ?? DateTime.now(),
      isRead: json['isRead'] ?? false, 
    );
  }
}
