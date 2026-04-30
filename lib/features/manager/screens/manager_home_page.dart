import 'package:ct484tx_project_trangdc24v7x324/features/manager/screens/manager_categories_page.dart';
import 'package:ct484tx_project_trangdc24v7x324/features/manager/screens/manager_products_page.dart';
import 'package:ct484tx_project_trangdc24v7x324/providers/chat_provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/providers/order_provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/providers/profile_provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ManagerHomePage extends StatefulWidget {
  const ManagerHomePage({super.key});

  @override
  State<ManagerHomePage> createState() => _ManagerHomePageState();
}

class _ManagerHomePageState extends State<ManagerHomePage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      _loadData();
      context.read<ChatProvider>().listenChatRooms();
    });
  }

  Future<void> _loadData() async {
    await context.read<OrderProvider>().loadAllOrders();
    await context.read<ProfileProvider>().loadProfile(forceReload: true);
  }

  void _openPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final chatProvider = context.watch<ChatProvider>();

    final avatarUrl = profileProvider.profile?.avatarUrl;

    final actions = [
      _ManagerActionData(
        icon: Icons.category_rounded,
        title: 'Quản lý danh mục',
        subtitle: 'Thêm, sửa, xóa danh mục sản phẩm',
        color: const Color(0xFFF3F0FF),
        iconColor: Colors.deepPurple,
        onTap: () => _openPage(const ManagerCategoriesPage()),
      ),
      _ManagerActionData(
        icon: Icons.fastfood_rounded,
        title: 'Quản lý sản phẩm',
        subtitle: 'Thêm, sửa, xóa và cập nhật sản phẩm',
        color: const Color(0xFFFFEEF0),
        iconColor: const Color(0xFFEF2A39),
        onTap: () => _openPage(const ManagerProductsPage()),
      ),

      _ManagerActionData(
        icon: Icons.receipt_long_rounded,
        title: 'Quản lý đơn hàng',
        subtitle: 'Xem, lọc và xử lý đơn hàng của khách',
        color: const Color(0xFFF0F3FF),
        iconColor: Colors.indigo,
        badgeCount: orderProvider.pendingOrderCount,
        onTap: () => Navigator.pushNamed(context, AppRoutes.managerOrders),
      ),
      _ManagerActionData(
        icon: Icons.bar_chart_rounded,
        title: 'Doanh thu',
        subtitle: 'Tổng hợp số lượng đơn và số tiền bán hàng',
        color: const Color(0xFFEFFFF3),
        iconColor: Colors.green,
        onTap: () => Navigator.pushNamed(context, AppRoutes.managerRevenue),
      ),
      _ManagerActionData(
        icon: Icons.chat_bubble_rounded,
        title: 'Chat phản hồi',
        subtitle:
            chatProvider.totalRooms > 0
                ? '${chatProvider.totalRooms} cuộc trò chuyện với khách hàng'
                : 'Xem và phản hồi tin nhắn từ khách hàng',
        color: const Color(0xFFEFF5FF),
        iconColor:
            chatProvider.unreadCount > 0
                ? const Color(0xFFEF2A39)
                : Colors.blue,
        badgeCount: chatProvider.unreadCount,
        onTap: () => Navigator.pushNamed(context, AppRoutes.managerChat),
      ),
      _ManagerActionData(
        icon: Icons.notifications_active_rounded,
        title: 'Tạo thông báo',
        subtitle: 'Gửi thông báo khuyến mãi hoặc cập nhật mới',
        color: const Color(0xFFFFF6E8),
        iconColor: Colors.orange,
        onTap:
            () => Navigator.pushNamed(context, AppRoutes.managerNotifications),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFEF2A39),
      body: Column(
        children: [
          _ManagerHeader(avatarUrl: avatarUrl),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: SafeArea(
                  top: false,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final horizontalPadding = width >= 700 ? 24.0 : 16.0;

                      return ListView(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          20,
                          horizontalPadding,
                          28,
                        ),
                        children: [
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 760),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _DashboardGrid(
                                    pending: orderProvider.pendingOrderCount,
                                    completed:
                                        orderProvider.completedOrderCount,
                                    unread: chatProvider.unreadCount,
                                    totalRooms: chatProvider.totalRooms,
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Chức năng quản lý',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2D2D2D),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  ...actions.map(
                                    (action) =>
                                        _ManagerActionCard(data: action),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagerHeader extends StatelessWidget {
  final String? avatarUrl;

  const _ManagerHeader({required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isSmall = width < 380;

    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        color: const Color(0xFFEF2A39),
        padding: EdgeInsets.fromLTRB(
          isSmall ? 16 : 18,
          12,
          isSmall ? 16 : 18,
          16,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YourFood',
                          style: GoogleFonts.lobster(
                            fontSize: isSmall ? 26 : 30,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bảng điều khiển quản lý',
                          style: TextStyle(
                            fontSize: isSmall ? 13 : 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.84),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                  child: Container(
                    width: isSmall ? 42 : 46,
                    height: isSmall ? 42 : 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child:
                          avatarUrl != null && avatarUrl!.isNotEmpty
                              ? Image.network(
                                avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => const Icon(
                                      Icons.person_outline,
                                      color: Colors.grey,
                                    ),
                              )
                              : const Icon(
                                Icons.person_outline,
                                color: Colors.grey,
                              ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  final int pending;
  final int completed;
  final int unread;
  final int totalRooms;

  const _DashboardGrid({
    required this.pending,
    required this.completed,
    required this.unread,
    required this.totalRooms,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _DashboardCard(
        title: 'Đơn xử lý',
        value: pending.toString(),
        icon: Icons.pending_actions_rounded,
        color: Colors.orange,
      ),
      _DashboardCard(
        title: 'Hoàn thành',
        value: completed.toString(),
        icon: Icons.check_circle_outline_rounded,
        color: Colors.green,
      ),
      _DashboardCard(
        title: 'Tin chưa đọc',
        value: unread.toString(),
        icon: Icons.mark_chat_unread_rounded,
        color: Colors.blue,
      ),
      _DashboardCard(
        title: 'Cuộc chat',
        value: totalRooms.toString(),
        icon: Icons.forum_rounded,
        color: Colors.purple,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 560;
        final crossAxisCount = isWide ? 4 : 2;
        final itemWidth =
            (constraints.maxWidth - (12 * (crossAxisCount - 1))) /
            crossAxisCount;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              cards
                  .map((card) => SizedBox(width: itemWidth, child: card))
                  .toList(),
        );
      },
    );
  }
}

class _ManagerActionData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;
  final int badgeCount;

  const _ManagerActionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
    required this.onTap,
    this.badgeCount = 0,
  });
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isSmall = width < 380;

    return Container(
      constraints: const BoxConstraints(minHeight: 82),
      padding: EdgeInsets.all(isSmall ? 10 : 12),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _IconBox(
            icon: icon,
            color: color,
            size: isSmall ? 40 : 44,
            iconSize: isSmall ? 22 : 25,
          ),
          SizedBox(width: isSmall ? 8 : 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isSmall ? 11.5 : 12.5,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagerActionCard extends StatelessWidget {
  final _ManagerActionData data;

  const _ManagerActionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final hasBadge = data.badgeCount > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: data.onTap,
          child: Ink(
            padding: const EdgeInsets.all(15),
            decoration: _cardDecoration(radius: 20),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _IconBox(
                      icon: data.icon,
                      color: data.iconColor,
                      backgroundColor: data.color,
                      size: 54,
                      iconSize: 29,
                    ),
                    if (hasBadge) _Badge(count: data.badgeCount),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.8,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.8,
                          color: Colors.grey.shade700,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 17,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color? backgroundColor;
  final double size;
  final double iconSize;

  const _IconBox({
    required this.icon,
    required this.color,
    this.backgroundColor,
    this.size = 44,
    this.iconSize = 25,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;

  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: -5,
      top: -6,
      child: Container(
        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFEF2A39),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
          child: Text(
            count > 99 ? '99+' : count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration({double radius = 18}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: Colors.grey.shade100),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.045),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ],
  );
}
