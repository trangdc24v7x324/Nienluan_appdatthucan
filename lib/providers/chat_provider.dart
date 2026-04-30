import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/chat_message_model.dart';
import '../models/chat_room_model.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  StreamSubscription<List<ChatRoomModel>>? _roomSub;
  StreamSubscription<List<ChatMessageModel>>? _messageSub;

  List<ChatRoomModel> _rooms = [];
  List<ChatMessageModel> _messages = [];

  ChatRoomModel? _selectedRoom;

  bool _isLoadingRooms = false;
  bool _isLoadingMessages = false;
  bool _isSending = false;
  String? _error;

  List<ChatRoomModel> get rooms => _rooms;
  List<ChatMessageModel> get messages => _messages;

  ChatRoomModel? get selectedRoom => _selectedRoom;

  bool get isLoadingRooms => _isLoadingRooms;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isSending => _isSending;
  String? get error => _error;

  int get totalRooms => _rooms.length;

  int get unreadCount {
    return _rooms.where((room) => room.unreadForManager > 0).length;
  }

  bool get hasUnread => unreadCount > 0;

  void listenChatRooms() {
    _roomSub?.cancel();

    _isLoadingRooms = true;
    _error = null;
    notifyListeners();

    _roomSub = _chatService.getChatRooms().listen(
      (rooms) {
        _rooms = rooms;
        _isLoadingRooms = false;

        if (_selectedRoom != null) {
          final index = _rooms.indexWhere(
            (room) => room.id == _selectedRoom!.id,
          );

          if (index != -1) {
            _selectedRoom = _rooms[index];
          }
        }

        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoadingRooms = false;
        notifyListeners();
      },
    );
  }

  void listenMessages(String userId) {
    _messageSub?.cancel();

    _isLoadingMessages = true;
    _error = null;
    notifyListeners();

    _messageSub = _chatService
        .getMessages(userId)
        .listen(
          (messages) {
            _messages = messages;
            _isLoadingMessages = false;
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            _isLoadingMessages = false;
            notifyListeners();
          },
        );
  }

  void selectRoom(ChatRoomModel room) {
    _selectedRoom = room;
    listenMessages(room.userId);
    notifyListeners();
  }

  void clearSelectedRoom() {
    _selectedRoom = null;
    _messages = [];
    _messageSub?.cancel();
    notifyListeners();
  }

  Future<void> sendTextMessage({
    required String userId,
    required String userName,
    String? userAvatar,
    required String senderId,
    required String senderRole,
    required String message,
  }) async {
    if (message.trim().isEmpty) return;

    try {
      _isSending = true;
      _error = null;
      notifyListeners();

      await _chatService.sendTextMessage(
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
        senderId: senderId,
        senderRole: senderRole,
        message: message.trim(),
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> sendImageMessage({
    required String userId,
    required String userName,
    String? userAvatar,
    required String senderId,
    required String senderRole,
    required File imageFile,
  }) async {
    try {
      _isSending = true;
      _error = null;
      notifyListeners();

      await _chatService.sendImageMessage(
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
        senderId: senderId,
        senderRole: senderRole,
        imageFile: imageFile,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead({
    required String userId,
    required String readerRole,
  }) async {
    try {
      await _chatService.markAsRead(userId: userId, readerRole: readerRole);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> setOnlineStatus({
    required String userId,
    required String role,
    required bool isOnline,
  }) async {
    try {
      await _chatService.setOnlineStatus(
        userId: userId,
        role: role,
        isOnline: isOnline,
      );
    } catch (_) {}
  }

  ChatRoomModel? getRoomById(String roomId) {
    try {
      return _rooms.firstWhere((room) => room.id == roomId);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _roomSub?.cancel();
    _messageSub?.cancel();
    super.dispose();
  }
}
