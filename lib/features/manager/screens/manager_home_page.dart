import 'package:flutter/material.dart';
import 'package:ct484tx_project_trangdc24v7x324/routes/app_routes.dart';
import 'package:ct484tx_project_trangdc24v7x324/services/auth_service.dart';
import 'package:ct484tx_project_trangdc24v7x324/features/manager/screens/manager_products_page.dart';

class ManagerHomePage extends StatelessWidget {
  const ManagerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Trang quản lý'),
        centerTitle: true,
        backgroundColor: const Color(0xFFEF2A39),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFEF2A39),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Xin chào Manager',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    authService.currentUserEmail.isNotEmpty
                        ? authService.currentUserEmail
                        : 'Quản trị hệ thống',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Bạn đang ở khu vực quản lý hệ thống, có thể theo dõi sản phẩm, đơn hàng và điều hướng nhanh đến các chức năng quản trị.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Chức năng quản lý',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D2D2D),
              ),
            ),

            const SizedBox(height: 14),

            _ManagerActionCard(
              icon: Icons.fastfood_rounded,
              title: 'Quản lý sản phẩm',
              subtitle: 'Thêm, sửa, xóa sản phẩm',
              color: const Color(0xFFFFF3F4),
              iconColor: const Color(0xFFEF2A39),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManagerProductsPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _ManagerActionCard(
              icon: Icons.receipt_long_rounded,
              title: 'Quản lý đơn hàng',
              subtitle: 'Xem và theo dõi đơn hàng của khách',
              color: const Color(0xFFF5F7FF),
              iconColor: Colors.indigo,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.orders);
              },
            ),

            const SizedBox(height: 12),

            _ManagerActionCard(
              icon: Icons.person_outline_rounded,
              title: 'Thông tin tài khoản',
              subtitle: 'Xem hồ sơ quản lý',
              color: const Color(0xFFF4FFF7),
              iconColor: Colors.green,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.profile);
              },
            ),

            const SizedBox(height: 12),

            _ManagerActionCard(
              icon: Icons.logout_rounded,
              title: 'Đăng xuất',
              subtitle: 'Thoát khỏi tài khoản quản lý',
              color: const Color(0xFFFFF8F1),
              iconColor: Colors.orange,
              onTap: () {
                authService.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              },
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Color(0xFFEF2A39)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Hiện tại mới thực hiện được tính năng thêm, xóa, sửa sản phẩm. Quản lý đơn hàng đang triển khai.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagerActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _ManagerActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ManagerProductsPlaceholderPage extends StatelessWidget {
  const ManagerProductsPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý sản phẩm'),
        centerTitle: true,
        backgroundColor: const Color(0xFFEF2A39),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 56,
                color: Color(0xFFEF2A39),
              ),
              SizedBox(height: 16),
              Text(
                'Dữ liệu sản phẩm hiện đang là dữ liệu tĩnh',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 10),
              Text(
                'Bạn cần kết nối collection products từ PocketBase trước, sau đó mới làm tiếp chức năng thêm, sửa, xóa sản phẩm cho manager.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
