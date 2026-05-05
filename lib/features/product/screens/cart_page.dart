import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:CT466_project_trangdc24v7x324/providers/cart_provider.dart';
import 'package:CT466_project_trangdc24v7x324/routes/app_routes.dart';

// DESIGN SYSTEM
import 'package:CT466_project_trangdc24v7x324/shared/theme/app_colors.dart';
import 'package:CT466_project_trangdc24v7x324/shared/theme/app_text.dart';

import 'package:CT466_project_trangdc24v7x324/shared/widgets/app_layout.dart';
import 'package:CT466_project_trangdc24v7x324/shared/widgets/app_card.dart';
import 'package:CT466_project_trangdc24v7x324/shared/widgets/app_body.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  String formatPrice(double price) {
    final text = price.round().toString();
    final result = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final positionFromEnd = text.length - i;
      result.write(text[i]);
      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        result.write('.');
      }
    }

    return '${result}đ';
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return AppLayout(
      title: 'Đơn hàng của bạn',
      showBack: true,
      child: AppBody(
        child:
            cart.items.isEmpty
                ? const _EmptyCart()
                : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                        itemCount: cart.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = cart.items[index];

                          return _CartItemCard(
                            title: item.title,
                            image: item.image,
                            price: formatPrice(item.price),
                            subtotal: formatPrice(item.price * item.quantity),
                            quantity: item.quantity,
                            onDecrease: () => cart.decreaseQty(item),
                            onIncrease: () => cart.increaseQty(item),
                          );
                        },
                      ),
                    ),

                    _CheckoutBox(
                      total: formatPrice(cart.totalPrice),
                      onCheckout: () {
                        Navigator.pushNamed(context, AppRoutes.payment);
                      },
                    ),
                  ],
                ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Giỏ hàng đang trống', style: AppText.body));
  }
}

class _CartItemCard extends StatelessWidget {
  final String title;
  final String image;
  final String price;
  final String subtotal;
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _CartItemCard({
    required this.title,
    required this.image,
    required this.price,
    required this.subtotal,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          _CartImage(image: image),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.productTitle),
                const SizedBox(height: 6),
                Text(price, style: AppText.price),
                const SizedBox(height: 8),

                _QuantityControl(
                  quantity: quantity,
                  onDecrease: onDecrease,
                  onIncrease: onIncrease,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Tạm tính',
                style: TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
              const SizedBox(height: 4),
              Text(
                subtotal,
                style: AppText.productTitle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CartImage extends StatelessWidget {
  final String image;

  const _CartImage({required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: _FoodImage(image: image),
    );
  }
}

class _FoodImage extends StatelessWidget {
  final String image;

  const _FoodImage({required this.image});

  @override
  Widget build(BuildContext context) {
    if (image.isEmpty) {
      return const Icon(Icons.fastfood, color: Colors.grey);
    }

    final isNetwork =
        image.startsWith('http://') || image.startsWith('https://');

    return isNetwork
        ? Image.network(
          image,
          fit: BoxFit.contain,
          errorBuilder:
              (_, __, ___) => const Icon(Icons.fastfood, color: Colors.grey),
        )
        : Image.asset(
          image,
          fit: BoxFit.contain,
          errorBuilder:
              (_, __, ___) => const Icon(Icons.fastfood, color: Colors.grey),
        );
  }
}

class _QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _QuantityControl({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QtyButton(icon: Icons.remove, onTap: onDecrease),

        SizedBox(
          width: 38,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: AppText.productTitle,
          ),
        ),

        _QtyButton(icon: Icons.add, onTap: onIncrease),
      ],
    );
  }
}

class _CheckoutBox extends StatelessWidget {
  final String total;
  final VoidCallback onCheckout;

  const _CheckoutBox({required this.total, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('Tổng tiền', style: AppText.productTitle),
                const Spacer(),
                Text(total, style: AppText.total),
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
                onPressed: onCheckout,
                child: const Text(
                  'Thanh toán',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.bgLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: AppColors.textDark),
      ),
    );
  }
}
