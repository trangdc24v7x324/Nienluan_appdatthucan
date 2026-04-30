class ChatRoomModel {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String lastMessage;
  final DateTime updatedAt;
  final int unreadForManager;
  final int unreadForUser;
  final bool userOnline;
  final bool managerOnline;

  ChatRoomModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.lastMessage,
    required this.updatedAt,
    required this.unreadForManager,
    required this.unreadForUser,
    required this.userOnline,
    required this.managerOnline,
  });

  factory ChatRoomModel.fromMap(String id, Map<String, dynamic> map) {
    return ChatRoomModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Khách hàng',
      userAvatar: map['userAvatar'],
      lastMessage: map['lastMessage'] ?? '',
      updatedAt:
          map['updatedAt'] != null
              ? DateTime.tryParse(map['updatedAt']) ?? DateTime.now()
              : DateTime.now(),
      unreadForManager: map['unreadForManager'] ?? 0,
      unreadForUser: map['unreadForUser'] ?? 0,
      userOnline: map['userOnline'] ?? false,
      managerOnline: map['managerOnline'] ?? false,
    );
  }

  int getUnread(bool isManager) {
    return isManager ? unreadForManager : unreadForUser;
  }
}
