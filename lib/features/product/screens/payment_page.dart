import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:CT466_project_trangdc24v7x324/models/payment_method_model.dart';
import 'package:CT466_project_trangdc24v7x324/providers/cart_provider.dart';
import 'package:CT466_project_trangdc24v7x324/providers/order_provider.dart';
import 'package:CT466_project_trangdc24v7x324/providers/profile_provider.dart';
import 'package:CT466_project_trangdc24v7x324/routes/app_routes.dart';

// DESIGN SYSTEM
import 'package:CT466_project_trangdc24v7x324/shared/theme/app_colors.dart';
import 'package:CT466_project_trangdc24v7x324/shared/theme/app_text.dart';
import 'package:CT466_project_trangdc24v7x324/shared/widgets/app_layout.dart';
import 'package:CT466_project_trangdc24v7x324/shared/widgets/app_body.dart';
import 'package:CT466_project_trangdc24v7x324/shared/widgets/app_card.dart';

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
      final methods = profile?.paymentMethods ?? [];

      final defaultMethod =
          methods.where((m) => m.isDefault).isNotEmpty
              ? methods.firstWhere((m) => m.isDefault)
              : (methods.isNotEmpty ? methods.first : null);

      if (mounted) {
        setState(() {
          selectedMethod = defaultMethod?.title;
        });
      }
    });
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  String formatPrice(double price) {
    final text = price.round().toString();
    final result = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final pos = text.length - i;
      result.write(text[i]);
      if (pos > 1 && pos % 3 == 1) result.write('.');
    }

    return '${result}đ';
  }

  void _showPaymentPicker(List<PaymentMethodModel> methods) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Chọn phương thức thanh toán',
                  style: AppText.productTitle,
                ),
                const SizedBox(height: 12),

                ...methods.map((m) {
                  return RadioListTile<String>(
                    value: m.title,
                    groupValue: selectedMethod,
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() => selectedMethod = value);
                      Navigator.pop(context);
                    },
                    title: Text(m.title),
                    subtitle: Text(m.subtitle),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final profile = context.watch<ProfileProvider>().profile;

    final address =
        profile?.addresses.where((a) => a.isDefault).isNotEmpty == true
            ? profile!.addresses.firstWhere((a) => a.isDefault)
            : (profile != null && profile.addresses.isNotEmpty
                ? profile.addresses.first
                : null);

    final methods = profile?.paymentMethods ?? [];

    return AppLayout(
      title: 'Thanh toán',
      showBack: true,

      child: AppBody(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
          child: Column(
            children: [
              _addressSection(context, address),
              const SizedBox(height: 16),

              _paymentSection(methods),
              const SizedBox(height: 16),

              _noteSection(),
              const SizedBox(height: 20),

              _totalSection(context, cart, address),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addressSection(BuildContext context, dynamic address) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Địa chỉ giao hàng', style: AppText.productTitle),
              ),
              TextButton(
                onPressed:
                    () => Navigator.pushNamed(context, AppRoutes.profile),
                child: const Text('Thay đổi'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (address != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(address.receiverName, style: AppText.productTitle),
                const SizedBox(height: 4),
                Text(address.phoneNumber, style: AppText.body),
                const SizedBox(height: 4),
                Text(address.addressLine, style: AppText.body),
              ],
            )
          else
            Text(
              'Chưa có địa chỉ. Vui lòng thêm trong hồ sơ.',
              style: AppText.body.copyWith(color: AppColors.textGrey),
            ),
        ],
      ),
    );
  }

  Widget _paymentSection(List<PaymentMethodModel> methods) {
    if (methods.isEmpty) {
      return AppCard(
        child: Text(
          'Chưa có phương thức thanh toán',
          style: AppText.body.copyWith(color: AppColors.textGrey),
        ),
      );
    }

    final current = methods.firstWhere(
      (m) => m.title == selectedMethod,
      orElse: () => methods.first,
    );

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Phương thức thanh toán',
                  style: AppText.productTitle,
                ),
              ),
              TextButton(
                onPressed: () => _showPaymentPicker(methods),
                child: const Text('Thay đổi'),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Icon(Icons.payment_outlined, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${current.title}\n${current.subtitle}',
                  style: AppText.body,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _noteSection() {
    return AppCard(
      child: TextField(
        controller: noteController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: 'Ghi chú',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _totalSection(
    BuildContext context,
    CartProvider cart,
    dynamic address,
  ) {
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Text('Tổng thanh toán', style: AppText.productTitle),
              const Spacer(),
              Text(formatPrice(cart.totalPrice), style: AppText.total),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async {
                if (address == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng thêm địa chỉ giao hàng.'),
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

                final success = await orderProvider.placeOrder(
                  cart.items,
                  cart.totalPrice,
                  receiverName: address.receiverName,
                  receiverPhone: address.phoneNumber,
                  address: address.addressLine,
                  paymentMethod: selectedMethod!,
                  note: noteController.text.trim(),
                );

                if (!context.mounted) return;

                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        orderProvider.errorMessage ?? 'Đặt hàng thất bại',
                      ),
                    ),
                  );
                  return;
                }

                cart.clearCart();

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogContext) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: const Row(
                        children: [
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
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            Navigator.pushNamed(context, AppRoutes.orders);
                          },
                          child: const Text('Xem đơn hàng'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
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
}
