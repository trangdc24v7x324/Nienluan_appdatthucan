import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:CT466_project_trangdc24v7x324/core/pocketbase_client.dart';
import 'package:CT466_project_trangdc24v7x324/models/chat_message_model.dart';
import 'package:CT466_project_trangdc24v7x324/providers/chat_provider.dart';
import 'package:CT466_project_trangdc24v7x324/shared/theme/app_colors.dart';
import 'package:CT466_project_trangdc24v7x324/shared/theme/app_text.dart';
import 'package:CT466_project_trangdc24v7x324/shared/widgets/app_body.dart';
import 'package:CT466_project_trangdc24v7x324/shared/widgets/app_layout.dart';

class ChatPage extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const ChatPage({
    super.key,
    required this.otherUserId,
    this.otherUserName = 'Người dùng',
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final String currentUserId;

  @override
  void initState() {
    super.initState();

    currentUserId = pb.authStore.model?.id ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (currentUserId.isEmpty || widget.otherUserId.isEmpty) return;

      final chatProvider = context.read<ChatProvider>();

      await chatProvider.loadMessages(
        currentUserId: currentUserId,
        otherUserId: widget.otherUserId,
        markRead: true,
      );

      if (!mounted) return;

      await chatProvider.subscribeMessages(
        currentUserId: currentUserId,
        otherUserId: widget.otherUserId,
      );

      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    context.read<ChatProvider>().unsubscribe();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty || currentUserId.isEmpty || widget.otherUserId.isEmpty) {
      return;
    }

    _messageController.clear();

    final success = await context.read<ChatProvider>().sendMessage(
      senderId: currentUserId,
      receiverId: widget.otherUserId,
      content: text,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gửi tin nhắn thất bại')));
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
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
    return AppLayout(
      title: widget.otherUserName,
      showBack: true,
      child: AppBody(
        child: Column(
          children: [
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, _) {
                  final messages = chatProvider.messages;

                  if (chatProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (messages.isEmpty) {
                    return const _EmptyChat();
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];

                      final isMe = chatProvider.isMessageMine(
                        message: message,
                        currentUserId: currentUserId,
                      );

                      final statusText = chatProvider.getMessageStatusText(
                        message: message,
                        currentUserId: currentUserId,
                      );

                      return _ChatBubble(
                        message: message,
                        isMe: isMe,
                        statusText: statusText,
                      );
                    },
                  );
                },
              ),
            ),
            Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                return _ChatInput(
                  controller: _messageController,
                  isSending: chatProvider.isSending,
                  onSend: _sendMessage,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Bạn chưa có tin nhắn nào.\nHãy gửi tin nhắn để bắt đầu cuộc trò chuyện!',
          textAlign: TextAlign.center,
          style: AppText.body.copyWith(color: AppColors.textGrey),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;
  final String statusText;

  const _ChatBubble({
    required this.message,
    required this.isMe,
    required this.statusText,
  });

  String _formatMessageTime(DateTime? time) {
    if (time == null) return '';

    final now = DateTime.now();
    final diff = now.difference(time);

    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    // Tin nhắn trong ngày: 10:54
    if (diff.inDays == 0 &&
        now.day == time.day &&
        now.month == time.month &&
        now.year == time.year) {
      return '$hour:$minute';
    }

    final day = time.day.toString().padLeft(2, '0');
    final month = time.month.toString().padLeft(2, '0');

    // Tin nhắn khác ngày: 10:54 05/05
    return '$hour:$minute $day/$month';
  }

  String _buildMetaText() {
    final timeText = _formatMessageTime(message.created);

    if (timeText.isEmpty && statusText.isEmpty) {
      return '';
    }

    if (isMe) {
      if (timeText.isNotEmpty && statusText.isNotEmpty) {
        return '$timeText • $statusText';
      }

      return timeText.isNotEmpty ? timeText : statusText;
    }

    return timeText;
  }

  @override
  Widget build(BuildContext context) {
    final metaText = _buildMetaText();

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Text(
                message.content,
                style: AppText.body.copyWith(
                  color: isMe ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
            if (metaText.isNotEmpty) ...[
              const SizedBox(height: 3),
              Padding(
                padding: EdgeInsets.only(
                  left: isMe ? 0 : 4,
                  right: isMe ? 4 : 0,
                ),
                child: Text(
                  metaText,
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const _ChatInput({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !isSending,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) {
                if (!isSending) onSend();
              },
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn...',
                hintStyle: AppText.body.copyWith(color: AppColors.textGrey),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: isSending ? null : onSend,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isSending ? Colors.grey : AppColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child:
                  isSending
                      ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
