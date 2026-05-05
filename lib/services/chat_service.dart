import 'package:CT466_project_trangdc24v7x324/core/pocketbase_client.dart';
import 'package:CT466_project_trangdc24v7x324/models/chat_message_model.dart';
import 'package:pocketbase/pocketbase.dart';

class ChatService {
  Future<List<ChatMessageModel>> getMessages({
    required String currentUserId,
    required String otherUserId,
  }) async {
    final records = await pb
        .collection('messages')
        .getFullList(
          sort: 'created',
          filter:
              '(sender = "$currentUserId" && receiver = "$otherUserId") || '
              '(sender = "$otherUserId" && receiver = "$currentUserId")',
        );

    return records.map((record) {
      return ChatMessageModel.fromJson({
        'id': record.id,
        ...record.data,
        'created': record.created,
        'updated': record.updated,
      });
    }).toList();
  }

  Future<ChatMessageModel> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    final text = content.trim();

    if (text.isEmpty) {
      throw Exception('Nội dung tin nhắn trống');
    }

    final record = await pb
        .collection('messages')
        .create(
          body: {
            'sender': senderId,
            'receiver': receiverId,
            'content': text,
            'isRead': false,
          },
        );

    return ChatMessageModel.fromJson({
      'id': record.id,
      ...record.data,
      'created': record.created,
      'updated': record.updated,
    });
  }

  Future<void> markAsRead(String messageId) async {
    await pb.collection('messages').update(messageId, body: {'isRead': true});
  }

  Future<void> markAllAsRead({
    required String senderId,
    required String receiverId,
  }) async {
    final records = await pb
        .collection('messages')
        .getFullList(
          filter:
              'sender = "$senderId" && receiver = "$receiverId" && isRead = false',
        );

    for (final record in records) {
      await markAsRead(record.id);
    }
  }

  Future<int> countUnreadForUser({required String userId}) async {
    final records = await pb
        .collection('messages')
        .getFullList(filter: 'receiver = "$userId" && isRead = false');

    return records.length;
  }

  Future<List<RecordModel>> getUserChatRecords({required String userId}) async {
    return pb
        .collection('messages')
        .getFullList(
          sort: '-created',
          filter: 'sender = "$userId" || receiver = "$userId"',
          expand: 'sender,receiver',
        );
  }

  Future<String?> getManagerId() async {
    final result = await pb
        .collection('users')
        .getList(
          page: 1,
          perPage: 1,
          filter: 'role = "manager" && isActive = true',
        );

    if (result.items.isEmpty) return null;

    return result.items.first.id;
  }

  Future<void> subscribeMessages({
    required void Function(RecordSubscriptionEvent event) onMessage,
  }) async {
    await pb.collection('messages').subscribe('*', onMessage);
  }

  Future<void> unsubscribeMessages() async {
    await pb.collection('messages').unsubscribe('*');
  }
}
