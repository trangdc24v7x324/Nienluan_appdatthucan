import 'package:flutter/material.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/order_history_model.dart';
import 'section_card.dart';

class OrderHistorySection extends StatelessWidget {
  final List<OrderHistoryModel> orders;
  final VoidCallback? onViewAll;

  const OrderHistorySection({super.key, required this.orders, this.onViewAll});

  String _formatMoney(double amount) {
    final value = amount.toInt().toString();
    final buffer = StringBuffer();
    int count = 0;

    for (int i = value.length - 1; i >= 0; i--) {
      buffer.write(value[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }

    return '${buffer.toString().split('').reversed.join()}đ';
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Lịch sử mua hàng',
      trailing: TextButton(
        onPressed: onViewAll,
        child: const Text('Xem tất cả'),
      ),
      child: Column(
        children: orders.map((order) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              child: Icon(Icons.receipt_long_outlined),
            ),
            title: Text(
              order.orderCode,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('${order.itemCount} món • ${order.status}'),
            trailing: Text(
              _formatMoney(order.totalAmount),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
      ),
    );
  }
}
