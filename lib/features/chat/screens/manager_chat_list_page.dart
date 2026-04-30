import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/chat_room_model.dart';
import '../../../providers/chat_provider.dart';
import 'chat_page.dart';

class ManagerChatListPage extends StatefulWidget {
  const ManagerChatListPage({super.key});

  @override
  State<ManagerChatListPage> createState() => _ManagerChatListPageState();
}

class _ManagerChatListPageState extends State<ManagerChatListPage> {
  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final rooms = chatProvider.rooms;

    return Scaffold(
      backgroundColor: const Color(0xFFEF2A39),
      body: Column(
        children: [
          const _ManagerHeader(title: 'Tin nhắn khách hàng'),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Builder(
                builder: (_) {
                  if (chatProvider.isLoadingRooms) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFEF2A39),
                      ),
                    );
                  }

                  if (chatProvider.error != null) {
                    return _MessageState(
                      icon: Icons.error_outline_rounded,
                      title: 'Không tải được tin nhắn',
                      message: chatProvider.error!,
                      iconColor: Colors.red,
                    );
                  }

                  if (rooms.isEmpty) {
                    return const _MessageState(
                      icon: Icons.forum_outlined,
                      title: 'Chưa có cuộc trò chuyện nào',
                      message:
                          'Khi khách hàng nhắn tin, cuộc trò chuyện sẽ hiển thị tại đây.',
                      iconColor: Color(0xFF64748B),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final horizontalPadding =
                          constraints.maxWidth >= 700 ? 24.0 : 16.0;

                      return ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          20,
                          horizontalPadding,
                          28,
                        ),
                        itemCount: rooms.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final room = rooms[index];

                          return Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 760),
                              child: _ChatRoomTile(room: room),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagerHeader extends StatelessWidget {
  final String title;

  const _ManagerHeader({required this.title});

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
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isSmall ? 17 : 19,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 44, height: 44),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatRoomTile extends StatelessWidget {
  final ChatRoomModel room;

  const _ChatRoomTile({required this.room});

  @override
  Widget build(BuildContext context) {
    final hasUnread = room.unreadForManager > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => ChatPage(
                    userId: room.userId,
                    userName: room.userName,
                    userAvatar: room.userAvatar,
                    currentUserId: 'manager',
                    currentUserRole: 'manager',
                  ),
            ),
          );
        },
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: hasUnread ? const Color(0xFFEFF6FF) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color:
                  hasUnread ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              _UserAvatar(room: room, hasUnread: hasUnread),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.userName.isEmpty ? 'Khách hàng' : room.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.5,
                        color: const Color(0xFF1F2937),
                        fontWeight:
                            hasUnread ? FontWeight.w900 : FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      room.lastMessage.isEmpty
                          ? 'Chưa có tin nhắn'
                          : room.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color:
                            hasUnread
                                ? const Color(0xFF334155)
                                : Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight:
                            hasUnread ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (hasUnread)
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 26,
                    minHeight: 26,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Center(
                    child: Text(
                      room.unreadForManager > 99
                          ? '99+'
                          : '${room.unreadForManager}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final ChatRoomModel room;
  final bool hasUnread;

  const _UserAvatar({required this.room, required this.hasUnread});

  @override
  Widget build(BuildContext context) {
    final name = room.userName.trim();
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : 'K';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color:
                hasUnread ? const Color(0xFFDBEAFE) : const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
            border: Border.all(
              color: hasUnread ? const Color(0xFF60A5FA) : Colors.white,
              width: 2,
            ),
          ),
          child: ClipOval(
            child:
                room.userAvatar != null && room.userAvatar!.isNotEmpty
                    ? Image.network(
                      room.userAvatar!,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Center(
                            child: Text(
                              firstLetter,
                              style: TextStyle(
                                color:
                                    hasUnread
                                        ? const Color(0xFF2563EB)
                                        : const Color(0xFF64748B),
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ),
                    )
                    : Center(
                      child: Text(
                        firstLetter,
                        style: TextStyle(
                          color:
                              hasUnread
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF64748B),
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
          ),
        ),
        Positioned(
          right: 1,
          bottom: 1,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color:
                  room.userOnline
                      ? const Color(0xFF22C55E)
                      : const Color(0xFF94A3B8),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color iconColor;

  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Container(
          margin: const EdgeInsets.all(22),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 46, color: iconColor),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
