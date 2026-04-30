enum SenderRole { user, manager }

class ChatMessageModel {
  final String id;
  final String roomId;
  final String senderId;
  final SenderRole senderRole;
  final String message;
  final String? imageUrl;
  final String type;
  final DateTime createdAt;
  final bool isRead;

  ChatMessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderRole,
    required this.message,
    this.imageUrl,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });

  factory ChatMessageModel.fromMap(String id, Map<String, dynamic> map) {
    return ChatMessageModel(
      id: id,
      roomId: map['roomId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderRole:
          map['senderRole'] == 'manager' ? SenderRole.manager : SenderRole.user,
      message: map['message'] ?? '',
      imageUrl: map['imageUrl'],
      type: map['type'] ?? 'text',
      createdAt:
          map['createdAt'] != null
              ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
              : DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }
}
