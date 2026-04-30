import 'package:ct484tx_project_trangdc24v7x324/models/payment_method_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/providers/cart_provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/providers/order_provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/providers/profile_provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? selectedMethod;
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<ProfileProvider>().profile;
      final paymentMethods = profile?.paymentMethods ?? [];

      final defaultPaymentMethod =
          paymentMethods.where((m) => m.isDefault).isNotEmpty
              ? paymentMethods.firstWhere((m) => m.isDefault)
              : (paymentMethods.isNotEmpty ? paymentMethods.first : null);

      if (mounted) {
        setState(() {
          selectedMethod = defaultPaymentMethod?.title;
        });
      }
    });
  }

  void _showPaymentPicker(List<PaymentMethodModel> paymentMethods) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Chọn phương thức thanh toán',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3C2F2F),
                  ),
                ),
                const SizedBox(height: 12),
                ...paymentMethods.map((method) {
                  return RadioListTile<String>(
                    value: method.title,
                    groupValue: selectedMethod,
                    onChanged: (value) {
                      setState(() {
                        selectedMethod = value;
                      });
                      Navigator.pop(bottomSheetContext);
                    },
                    title: Text(method.title),
                    subtitle: Text(method.subtitle),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

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
    final cart = context.watch<CartProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;

    final defaultAddress =
        profile?.addresses.where((a) => a.isDefault).isNotEmpty == true
            ? profile!.addresses.firstWhere((a) => a.isDefault)
            : (profile != null && profile.addresses.isNotEmpty
                ? profile.addresses.first
                : null);

    final paymentMethods = profile?.paymentMethods ?? [];

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAddressSection(context, defaultAddress),
            const SizedBox(height: 16),
            _buildPaymentSection(paymentMethods),
            const SizedBox(height: 16),
            _buildNoteSection(),
            const SizedBox(height: 20),
            _buildTotalSection(context, cart, defaultAddress),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection(BuildContext context, dynamic defaultAddress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Địa chỉ giao hàng',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3C2F2F),
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pushNamed(context, AppRoutes.profile);
                },
                child: const Text('Thay đổi'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (defaultAddress != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFFEF2A39),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            defaultAddress.receiverName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF3C2F2F),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (defaultAddress.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEECEC),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Mặc định',
                                style: TextStyle(
                                  color: Color(0xFFEF2A39),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        defaultAddress.phoneNumber,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF555555),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        defaultAddress.fullAddress,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF555555),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            const Text(
              'Chưa có địa chỉ giao hàng. Vui lòng thêm địa chỉ trong trang cá nhân.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentSection(List<PaymentMethodModel> paymentMethods) {
    if (paymentMethods.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: const Text(
          'Chưa có phương thức thanh toán. Vui lòng thêm trong trang cá nhân.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }

    final currentMethod = paymentMethods.firstWhere(
      (m) => m.title == selectedMethod,
      orElse: () => paymentMethods.first,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Phương thức thanh toán',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3C2F2F),
                  ),
                ),
              ),
              TextButton(
                onPressed: () async => _showPaymentPicker(paymentMethods),
                child: const Text('Thay đổi'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.payment_outlined, color: Color(0xFFEF2A39)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentMethod.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentMethod.subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
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
    );
  }

  Widget _buildTotalSection(
    BuildContext context,
    CartProvider cart,
    dynamic defaultAddress,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Tổng thanh toán',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
              onPressed: () async {
                if (defaultAddress == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Vui lòng thêm địa chỉ giao hàng trước khi thanh toán.',
                      ),
                    ),
                  );
                  return;
                }

                if (selectedMethod == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng chọn phương thức thanh toán.'),
                    ),
                  );
                  return;
                }

                final orderProvider = context.read<OrderProvider>();

                await orderProvider.placeOrder(
                  cart.items,
                  cart.totalPrice,
                  receiverName: defaultAddress.receiverName,
                  receiverPhone: defaultAddress.phoneNumber,
                  address: defaultAddress.fullAddress,
                  paymentMethod: selectedMethod!,
                  note: noteController.text.trim(),
                );

                cart.clearCart();
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogContext) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Row(
                        children: const [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Thanh toán thành công',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      content: const Text('Đơn hàng của bạn đã được ghi nhận.'),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            Navigator.of(dialogContext).pop();
                            Navigator.pushNamed(context, AppRoutes.orders);
                          },
                          child: const Text('Xem đơn hàng'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF2A39),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            Navigator.of(dialogContext).pop();
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
      ],
    );
  }
}
