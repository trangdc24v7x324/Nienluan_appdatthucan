import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

import '../core/pocketbase_client.dart';
import '../models/chat_message_model.dart';
import '../models/chat_room_model.dart';

class ChatService {
  final PocketBase _pb = pb;

  String getRoomId(String userId) => 'room_$userId';

  Stream<List<ChatRoomModel>> getChatRooms() {
    final controller = StreamController<List<ChatRoomModel>>();

    Future<void> loadRooms() async {
      try {
        final records = await _pb
            .collection('chat_rooms')
            .getFullList(sort: '-updatedAt');

        final rooms =
            records.map((record) {
              return ChatRoomModel.fromMap(record.id, record.data);
            }).toList();

        if (!controller.isClosed) {
          controller.add(rooms);
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    }

    loadRooms();

    _pb.collection('chat_rooms').subscribe('*', (_) {
      loadRooms();
    });

    controller.onCancel = () {
      _pb.collection('chat_rooms').unsubscribe('*');
    };

    return controller.stream;
  }

  Stream<List<ChatMessageModel>> getMessages(String userId) {
    final controller = StreamController<List<ChatMessageModel>>();
    final roomId = getRoomId(userId);

    Future<void> loadMessages() async {
      try {
        final records = await _pb
            .collection('chat_messages')
            .getFullList(filter: 'roomId = "$roomId"', sort: 'createdAt');

        final messages =
            records.map((record) {
              return ChatMessageModel.fromMap(record.id, record.data);
            }).toList();

        if (!controller.isClosed) {
          controller.add(messages);
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    }

    loadMessages();

    _pb.collection('chat_messages').subscribe('*', (event) {
      final data = event.record?.data;

      if (data == null) return;
      if (data['roomId'] != roomId) return;

      loadMessages();
    });

    controller.onCancel = () {
      _pb.collection('chat_messages').unsubscribe('*');
    };

    return controller.stream;
  }

  Future<void> sendTextMessage({
    required String userId,
    required String userName,
    String? userAvatar,
    required String senderId,
    required String senderRole,
    required String message,
  }) async {
    await _sendMessage(
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      senderId: senderId,
      senderRole: senderRole,
      message: message,
      imageUrl: null,
      imageFile: null,
    );
  }

  Future<void> sendImageMessage({
    required String userId,
    required String userName,
    String? userAvatar,
    required String senderId,
    required String senderRole,
    required File imageFile,
  }) async {
    await _sendMessage(
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      senderId: senderId,
      senderRole: senderRole,
      message: '[Hình ảnh]',
      imageUrl: null,
      imageFile: imageFile,
    );
  }

  Future<void> _sendMessage({
    required String userId,
    required String userName,
    String? userAvatar,
    required String senderId,
    required String senderRole,
    required String message,
    String? imageUrl,
    File? imageFile,
  }) async {
    final roomId = getRoomId(userId);
    final now = DateTime.now().toIso8601String();

    final existingRoom = await _getRoom(roomId);

    final int unreadForManager = existingRoom?.data['unreadForManager'] ?? 0;
    final int unreadForUser = existingRoom?.data['unreadForUser'] ?? 0;

    final int newUnreadForManager =
        senderRole == 'user' ? unreadForManager + 1 : unreadForManager;

    final int newUnreadForUser =
        senderRole == 'manager' ? unreadForUser + 1 : unreadForUser;

    if (existingRoom == null) {
      await _pb
          .collection('chat_rooms')
          .create(
            body: {
              'roomId': roomId,
              'userId': userId,
              'userName': userName,
              'userAvatar': userAvatar,
              'lastMessage': message,
              'updatedAt': now,
              'unreadForManager': newUnreadForManager,
              'unreadForUser': newUnreadForUser,
              'userOnline': senderRole == 'user',
              'managerOnline': senderRole == 'manager',
            },
          );
    } else {
      await _pb
          .collection('chat_rooms')
          .update(
            existingRoom.id,
            body: {
              'userId': userId,
              'userName': userName,
              'userAvatar': userAvatar,
              'lastMessage': message,
              'updatedAt': now,
              'unreadForManager': newUnreadForManager,
              'unreadForUser': newUnreadForUser,
            },
          );
    }

    if (imageFile != null) {
      await _pb
          .collection('chat_messages')
          .create(
            body: {
              'roomId': roomId,
              'senderId': senderId,
              'senderRole': senderRole,
              'message': message,
              'createdAt': now,
              'isRead': false,
              'type': 'image',
            },
            files: [
              http.MultipartFile.fromBytes(
                'image',
                await imageFile.readAsBytes(),
                filename: imageFile.path.split('/').last,
              ),
            ],
          );
    } else {
      await _pb
          .collection('chat_messages')
          .create(
            body: {
              'roomId': roomId,
              'senderId': senderId,
              'senderRole': senderRole,
              'message': message,
              'imageUrl': imageUrl,
              'createdAt': now,
              'isRead': false,
              'type': 'text',
            },
          );
    }
  }

  Future<void> markAsRead({
    required String userId,
    required String readerRole,
  }) async {
    final roomId = getRoomId(userId);

    final existingRoom = await _getRoom(roomId);
    if (existingRoom == null) return;

    if (readerRole == 'manager') {
      await _pb
          .collection('chat_rooms')
          .update(existingRoom.id, body: {'unreadForManager': 0});
    } else {
      await _pb
          .collection('chat_rooms')
          .update(existingRoom.id, body: {'unreadForUser': 0});
    }

    final messages = await _pb
        .collection('chat_messages')
        .getFullList(filter: 'roomId = "$roomId" && isRead = false');

    for (final message in messages) {
      if (message.data['senderRole'] != readerRole) {
        await _pb
            .collection('chat_messages')
            .update(message.id, body: {'isRead': true});
      }
    }
  }

  Future<void> setOnlineStatus({
    required String userId,
    required String role,
    required bool isOnline,
  }) async {
    final roomId = getRoomId(userId);

    final existingRoom = await _getRoom(roomId);
    if (existingRoom == null) return;

    await _pb
        .collection('chat_rooms')
        .update(
          existingRoom.id,
          body: {role == 'manager' ? 'managerOnline' : 'userOnline': isOnline},
        );
  }

  Future<RecordModel?> _getRoom(String roomId) async {
    try {
      return await _pb
          .collection('chat_rooms')
          .getFirstListItem('roomId = "$roomId"');
    } catch (_) {
      return null;
    }
  }
}
