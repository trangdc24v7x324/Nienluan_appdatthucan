import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/providers/notification_provider.dart';

class ManagerNotificationsPage extends StatefulWidget {
  const ManagerNotificationsPage({super.key});

  @override
  State<ManagerNotificationsPage> createState() =>
      _ManagerNotificationsPageState();
}

class _ManagerNotificationsPageState extends State<ManagerNotificationsPage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  String selectedType = 'promotion';
  bool isLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> submit() async {
    final title = titleController.text.trim();
    final body = contentController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      _showMessage('Vui lòng nhập đầy đủ thông tin');
      return;
    }

    setState(() => isLoading = true);

    try {
      await context.read<NotificationProvider>().createManagerNotification(
        title: title,
        body: body,
        type: selectedType,
      );

      titleController.clear();
      contentController.clear();

      _showMessage('Đã gửi thông báo thành công');
    } catch (e) {
      debugPrint('create notification error: $e');
      _showMessage('Gửi thông báo thất bại');
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  InputDecoration _decoration({
    required String label,
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF22C55E), width: 1.4),
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'promotion':
        return 'Khuyến mãi';
      case 'new_product':
        return 'Sản phẩm mới';
      default:
        return 'Thông báo';
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'promotion':
        return Icons.local_offer_rounded;
      case 'new_product':
        return Icons.fastfood_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'promotion':
        return const Color(0xFFF97316);
      case 'new_product':
        return const Color(0xFF22C55E);
      default:
        return const Color(0xFF2563EB);
    }
  }

  Widget _buildPreviewCard() {
    final title =
        titleController.text.trim().isEmpty
            ? 'Tiêu đề thông báo'
            : titleController.text.trim();

    final body =
        contentController.text.trim().isEmpty
            ? 'Nội dung thông báo sẽ hiển thị tại đây.'
            : contentController.text.trim();

    final color = _typeColor(selectedType);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE0F2FE), Color(0xFFDCFCE7)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(_typeIcon(selectedType), color: color, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _typeLabel(selectedType),
                  style: TextStyle(
                    color: color,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 700 ? 24.0 : 16.0;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            20,
            horizontalPadding,
            28,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  titleController,
                  contentController,
                ]),
                builder: (context, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Xem trước thông báo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPreviewCard(),
                      const SizedBox(height: 22),
                      const Text(
                        'Nội dung gửi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: titleController,
                        enabled: !isLoading,
                        decoration: _decoration(
                          label: 'Tiêu đề thông báo',
                          hint: 'VD: Ưu đãi hôm nay',
                          icon: Icons.title_rounded,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: contentController,
                        enabled: !isLoading,
                        maxLines: 5,
                        decoration: _decoration(
                          label: 'Nội dung thông báo',
                          hint: 'Nhập nội dung muốn gửi đến khách hàng...',
                          icon: Icons.notes_rounded,
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: _decoration(
                          label: 'Loại thông báo',
                          icon: Icons.notifications_active_rounded,
                        ),
                        dropdownColor: Colors.white,
                        items: const [
                          DropdownMenuItem(
                            value: 'promotion',
                            child: Text('Khuyến mãi'),
                          ),
                          DropdownMenuItem(
                            value: 'new_product',
                            child: Text('Sản phẩm mới'),
                          ),
                        ],
                        onChanged:
                            isLoading
                                ? null
                                : (value) {
                                  if (value != null) {
                                    setState(() => selectedType = value);
                                  }
                                },
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : submit,
                          icon:
                              isLoading
                                  ? const SizedBox(
                                    width: 19,
                                    height: 19,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.3,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Icon(Icons.send_rounded),
                          label: Text(
                            isLoading ? 'Đang gửi...' : 'Gửi thông báo',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF22C55E),
                            disabledBackgroundColor: Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEF2A39),
      body: Column(
        children: [
          const _ManagerHeader(title: 'Tạo thông báo'),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: _buildForm(),
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
