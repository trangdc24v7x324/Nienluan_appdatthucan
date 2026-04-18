import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/providers/cart_provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/providers/profile_provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/routes/app_routes.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedMethod = 'Tiền mặt';
  final TextEditingController noteController = TextEditingController();

  String formatPrice(double price) {
    final int value = price.round();
    final String text = value.toString();
    final StringBuffer result = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final int positionFromEnd = text.length - i;
      result.write(text[i]);
      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        result.write('.');
      }
    }

    return '${result.toString()}đ';
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        title: const Text(
          'Thanh toán',
          style: TextStyle(
            color: Color(0xFF3C2F2F),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF3C2F2F)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Phương thức thanh toán',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3C2F2F),
                    ),
                  ),
                  const SizedBox(height: 12),

                  RadioListTile<String>(
                    value: 'Tiền mặt',
                    groupValue: selectedMethod,
                    onChanged: (value) {
                      setState(() {
                        selectedMethod = value!;
                      });
                    },
                    title: const Text('Tiền mặt'),
                  ),
                  RadioListTile<String>(
                    value: 'MoMo',
                    groupValue: selectedMethod,
                    onChanged: (value) {
                      setState(() {
                        selectedMethod = value!;
                      });
                    },
                    title: const Text('MoMo'),
                  ),
                  RadioListTile<String>(
                    value: 'Visa',
                    groupValue: selectedMethod,
                    onChanged: (value) {
                      setState(() {
                        selectedMethod = value!;
                      });
                    },
                    title: const Text('Visa'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ghi chú đơn hàng',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3C2F2F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Ví dụ: ít đá, không hành...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Tổng thanh toán',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formatPrice(cart.totalPrice),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEF2A39),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF2A39),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        profileProvider.addOrder(
                          cart.items,
                          cart.totalPrice,
                          paymentMethod: selectedMethod,
                          note: noteController.text.trim(),
                        );

                        cart.clearCart();

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Text(
                                '🎉 Thanh toán thành công',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              content: const Text(
                                'Đơn hàng của bạn đã được ghi nhận.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // đóng dialog

                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      AppRoutes.home,
                                      (route) => false,
                                      arguments: {'index': 3}, // tab Orders
                                    );
                                  },
                                  child: const Text('Xem đơn hàng'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEF2A39),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context); // đóng dialog

                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      AppRoutes.home,
                                      (route) => false,
                                    );
                                  },
                                  child: const Text('Về trang chủ'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text(
                        'Xác nhận thanh toán',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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
