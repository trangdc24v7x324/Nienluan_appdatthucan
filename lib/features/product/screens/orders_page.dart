import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:CT466_project_trangdc24v7x324/providers/order_provider.dart';
import 'package:CT466_project_trangdc24v7x324/utils/order_status_helper.dart';

// DESIGN SYSTEM
import 'package:CT466_project_trangdc24v7x324/shared/theme/app_colors.dart';
import 'package:CT466_project_trangdc24v7x324/shared/theme/app_text.dart';
import 'package:CT466_project_trangdc24v7x324/shared/widgets/app_layout.dart';
import 'package:CT466_project_trangdc24v7x324/shared/widgets/app_body.dart';
import 'package:CT466_project_trangdc24v7x324/shared/widgets/app_card.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<OrderProvider>().loadOrders());
  }

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
    final provider = context.watch<OrderProvider>();
    final orders = provider.orders;

    return AppLayout(
      title: 'Lịch sử mua hàng',
      showBack: true,

      child: AppBody(
        child:
            provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : orders.isEmpty
                ? const _EmptyOrders()
                : RefreshIndicator(
                  onRefresh: () {
                    return context.read<OrderProvider>().loadOrders();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];

                      return _OrderCard(
                        orderId: order.id,
                        date:
                            '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}',
                        statusText: OrderStatusHelper.getText(order.status),
                        statusColor: OrderStatusHelper.getColor(order.status),
                        total: formatPrice(order.totalAmount),
                        receiver:
                            '${order.receiverName} - ${order.receiverPhone}',
                        address: order.address,
                        payment: order.paymentMethod,
                        note: order.note,
                        items:
                            order.items
                                .map(
                                  (item) => _OrderItemView(
                                    title: item.productName,
                                    quantity: item.quantity,
                                    total: formatPrice(item.subtotal),
                                  ),
                                )
                                .toList(),
                      );
                    },
                  ),
                ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Chưa có đơn hàng nào',
        style: AppText.body.copyWith(color: AppColors.textGrey),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String orderId;
  final String date;
  final String statusText;
  final Color statusColor;
  final String total;
  final String receiver;
  final String address;
  final String payment;
  final String note;
  final List<_OrderItemView> items;

  const _OrderCard({
    required this.orderId,
    required this.date,
    required this.statusText,
    required this.statusColor,
    required this.total,
    required this.receiver,
    required this.address,
    required this.payment,
    required this.note,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Đơn hàng #$orderId', style: AppText.productTitle),

          const SizedBox(height: 12),

          _InfoRow(
            icon: Icons.calendar_today_outlined,
            text: 'Ngày đặt: $date',
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Text('Trạng thái: ', style: AppText.body),
              _StatusBadge(text: statusText, color: statusColor),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Text('Tổng tiền: ', style: AppText.body),
              Text(total, style: AppText.price),
            ],
          ),

          const SizedBox(height: 8),
          _InfoRow(icon: Icons.person_outline, text: receiver),

          const SizedBox(height: 8),
          _InfoRow(icon: Icons.location_on_outlined, text: 'Địa chỉ: $address'),

          const SizedBox(height: 8),
          _InfoRow(icon: Icons.payment_outlined, text: 'Thanh toán: $payment'),

          if (note.isNotEmpty) ...[
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.note_alt_outlined, text: 'Ghi chú: $note'),
          ],

          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 8),

          Text('Món đã đặt', style: AppText.productTitle),

          const SizedBox(height: 10),
          ...items,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textGrey),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: AppText.body)),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _OrderItemView extends StatelessWidget {
  final String title;
  final int quantity;
  final String total;

  const _OrderItemView({
    required this.title,
    required this.quantity,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppText.productTitle)),
          Text(
            'x$quantity',
            style: AppText.body.copyWith(color: AppColors.textGrey),
          ),
          const SizedBox(width: 12),
          Text(total, style: AppText.body),
        ],
      ),
    );
  }
}
