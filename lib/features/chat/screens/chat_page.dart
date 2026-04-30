import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../models/chat_message_model.dart';
import '../../../services/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String userName;
  final String? userAvatar;
  final String currentUserId;
  final String currentUserRole;

  const ChatPage({
    super.key,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.currentUserId,
    required this.currentUserRole,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  bool _isSendingText = false;
  bool _isSendingImage = false;

  StreamSubscription<List<ChatMessageModel>>? _messageSub;
  List<ChatMessageModel> _messages = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _setOnline(true);
    _listenMessages();
    _markAsRead();
  }

  void _listenMessages() {
    _messageSub?.cancel();

    _messageSub = _chatService
        .getMessages(widget.userId)
        .listen(
          (messages) {
            if (!mounted) return;

            setState(() {
              _messages = messages;
            });

            _markAsRead();
            _scrollToBottom();
          },
          onError: (e) {
            if (!mounted) return;
            _showMessage('Lỗi tải tin nhắn: $e');
          },
        );
  }

  Future<void> _markAsRead() async {
    try {
      await _chatService.markAsRead(
        userId: widget.userId,
        readerRole: widget.currentUserRole,
      );
    } catch (_) {}
  }

  Future<void> _setOnline(bool value) async {
    try {
      await _chatService.setOnlineStatus(
        userId: widget.userId,
        role: widget.currentUserRole,
        isOnline: value,
      );
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _setOnline(state == AppLifecycleState.resumed);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _setOnline(false);
    _messageSub?.cancel();

    _messageController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _sendTextMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty || _isSendingText) return;

    setState(() {
      _isSendingText = true;
    });

    _messageController.clear();

    try {
      await _chatService.sendTextMessage(
        userId: widget.userId,
        userName: widget.userName,
        userAvatar: widget.userAvatar,
        senderId: widget.currentUserId,
        senderRole: widget.currentUserRole,
        message: text,
      );

      _scrollToBottom();
    } catch (e) {
      _showMessage('Không gửi được tin nhắn: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSendingText = false;
        });
      }
    }
  }

  Future<void> _pickAndSendImage() async {
    if (_isSendingImage) return;

    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1200,
    );

    if (pickedFile == null) return;

    setState(() {
      _isSendingImage = true;
    });

    try {
      await _chatService.sendImageMessage(
        userId: widget.userId,
        userName: widget.userName,
        userAvatar: widget.userAvatar,
        senderId: widget.currentUserId,
        senderRole: widget.currentUserRole,
        imageFile: File(pickedFile.path),
      );

      _scrollToBottom();
    } catch (e) {
      _showMessage('Không gửi được ảnh: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSendingImage = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isManager = widget.currentUserRole == 'manager';
    final title = isManager ? widget.userName : 'Chat với Shop';

    return Scaffold(
      backgroundColor: const Color(0xFFEF2A39),
      body: Column(
        children: [
          _ChatHeader(
            title: title,
            avatarUrl: widget.userAvatar,
            isManager: isManager,
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Expanded(
                    child:
                        _messages.isEmpty
                            ? const _EmptyChatState()
                            : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(
                                12,
                                18,
                                12,
                                10,
                              ),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final message = _messages[index];
                                final isMe =
                                    message.senderId == widget.currentUserId;

                                return _MessageBubble(
                                  message: message,
                                  isMe: isMe,
                                );
                              },
                            ),
                  ),
                  if (_isSendingImage || _isSendingText)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        _isSendingImage
                            ? 'Đang gửi ảnh...'
                            : 'Đang gửi tin nhắn...',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  _buildInputArea(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    final isSending = _isSendingText || _isSendingImage;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Material(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(99),
              child: InkWell(
                borderRadius: BorderRadius.circular(99),
                onTap: isSending ? null : _pickAndSendImage,
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(
                    Icons.image_rounded,
                    color: isSending ? Colors.grey : const Color(0xFF2563EB),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _messageController,
                enabled: !isSending,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendTextMessage(),
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: isSending ? Colors.grey.shade400 : const Color(0xFF22C55E),
              borderRadius: BorderRadius.circular(99),
              child: InkWell(
                borderRadius: BorderRadius.circular(99),
                onTap: isSending ? null : _sendTextMessage,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  final String title;
  final String? avatarUrl;
  final bool isManager;

  const _ChatHeader({
    required this.title,
    required this.avatarUrl,
    required this.isManager,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width < 380;

    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        color: const Color(0xFFEF2A39),
        padding: EdgeInsets.fromLTRB(
          isSmall ? 12 : 14,
          12,
          isSmall ? 12 : 14,
          16,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                ),
                _HeaderAvatar(avatarUrl: avatarUrl, isManager: isManager),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title.isEmpty ? 'Khách hàng' : title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isSmall ? 16.5 : 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  final String? avatarUrl;
  final bool isManager;

  const _HeaderAvatar({required this.avatarUrl, required this.isManager});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipOval(
        child:
            avatarUrl != null && avatarUrl!.isNotEmpty
                ? Image.network(
                  avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Icon(
                        isManager ? Icons.person : Icons.storefront,
                        color: const Color(0xFFEF2A39),
                        size: 22,
                      ),
                )
                : Icon(
                  isManager ? Icons.person : Icons.storefront,
                  color: const Color(0xFFEF2A39),
                  size: 22,
                ),
      ),
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(22),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 46,
              color: Color(0xFF94A3B8),
            ),
            SizedBox(height: 12),
            Text(
              'Hãy bắt đầu cuộc trò chuyện',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Gửi tin nhắn hoặc hình ảnh cho khách hàng tại đây.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final hasImage = message.imageUrl != null && message.imageUrl!.isNotEmpty;
    final time = DateFormat('HH:mm').format(message.createdAt);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  hasImage
                      ? const EdgeInsets.all(5)
                      : const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.74,
              ),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFFDCFCE7) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                border: Border.all(
                  color:
                      isMe ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.035),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child:
                  hasImage
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          message.imageUrl!,
                          width: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              width: 220,
                              height: 135,
                              alignment: Alignment.center,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image),
                            );
                          },
                        ),
                      )
                      : Text(
                        message.message,
                        style: TextStyle(
                          color:
                              isMe
                                  ? const Color(0xFF14532D)
                                  : const Color(0xFF1F2937),
                          fontSize: 15,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 5),
                    Icon(
                      message.isRead
                          ? Icons.done_all_rounded
                          : Icons.done_rounded,
                      size: 15,
                      color:
                          message.isRead
                              ? const Color(0xFF22C55E)
                              : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      message.isRead ? 'Đã xem' : 'Đã gửi',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
