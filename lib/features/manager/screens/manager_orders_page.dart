import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:CT466_project_trangdc24v7x324/models/order_model.dart';
import 'package:CT466_project_trangdc24v7x324/providers/order_provider.dart';
import 'package:CT466_project_trangdc24v7x324/shared/widgets/app_body.dart';
import 'package:CT466_project_trangdc24v7x324/shared/widgets/app_layout.dart';
import 'package:CT466_project_trangdc24v7x324/utils/order_status_helper.dart';

class ManagerOrdersPage extends StatefulWidget {
  const ManagerOrdersPage({super.key});

  @override
  State<ManagerOrdersPage> createState() => _ManagerOrdersPageState();
}

class _ManagerOrdersPageState extends State<ManagerOrdersPage> {
  String selectedFilter = 'processing';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<OrderProvider>().loadAllOrders());
  }

  Future<void> _refresh() async {
    await context.read<OrderProvider>().loadAllOrders();
  }

  String _getNextStatus(String status) {
    switch (status) {
      case 'placed':
        return 'confirmed';
      case 'confirmed':
        return 'preparing';
      case 'preparing':
        return 'delivering';
      case 'delivering':
        return 'completed';
      default:
        return '';
    }
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    if (selectedFilter == 'all') return orders;

    if (selectedFilter == 'processing') {
      return orders.where((order) => order.isActive).toList();
    }

    if (selectedFilter == 'completed') {
      return orders.where((order) => order.isCompleted).toList();
    }

    if (selectedFilter == 'cancelled') {
      return orders.where((order) => order.isCancelled).toList();
    }

    return orders
        .where((order) => order.orderStatus == selectedFilter)
        .toList();
  }

  String _formatPrice(double price) {
    final text = price.round().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      final remaining = text.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }

    return '${buffer}đ';
  }

  Future<void> _cancelOrder(OrderProvider provider, OrderModel order) async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Hủy đơn hàng'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Lý do hủy',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Không'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, controller.text),
              child: const Text('Hủy đơn'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null) return;

    await provider.updateOrderStatus(
      orderId: order.id,
      status: 'cancelled',
      cancelReason: result,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final orders = _filterOrders(provider.orders);

    return AppLayout(
      title: 'Quản lý đơn hàng',
      showBack: true,
      child: AppBody(
        child:
            provider.isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFEF2A39)),
                )
                : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                    children: [
                      _buildFilterBar(),
                      const SizedBox(height: 16),
                      if (orders.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 120),
                          child: Center(
                            child: Text(
                              'Không có đơn hàng',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        )
                      else
                        ...orders.map((order) {
                          final statusColor = OrderStatusHelper.getColor(
                            order.orderStatus,
                          );
                          final nextStatus = _getNextStatus(order.orderStatus);

                          return _OrderCard(
                            order: order,
                            statusColor: statusColor,
                            nextStatus: nextStatus,
                            onNext: () async {
                              if (nextStatus.isEmpty) return;
                              await provider.updateOrderStatus(
                                orderId: order.id,
                                status: nextStatus,
                              );
                            },
                            onCancel: () => _cancelOrder(provider, order),
                            formatPrice: _formatPrice,
                          );
                        }),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _FilterChipButton(
          label: 'Đang xử lý',
          selected: selectedFilter == 'processing',
          onTap: () => setState(() => selectedFilter = 'processing'),
        ),
        _FilterChipButton(
          label: 'Tất cả',
          selected: selectedFilter == 'all',
          onTap: () => setState(() => selectedFilter = 'all'),
        ),
        _FilterChipButton(
          label: 'Đã giao',
          selected: selectedFilter == 'completed',
          onTap: () => setState(() => selectedFilter = 'completed'),
        ),
        _FilterChipButton(
          label: 'Đã hủy',
          selected: selectedFilter == 'cancelled',
          onTap: () => setState(() => selectedFilter = 'cancelled'),
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final Color statusColor;
  final String nextStatus;
  final VoidCallback onNext;
  final VoidCallback onCancel;
  final String Function(double) formatPrice;

  const _OrderCard({
    required this.order,
    required this.statusColor,
    required this.nextStatus,
    required this.onNext,
    required this.onCancel,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đơn #${order.id}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text('${order.receiverName} - ${order.receiverPhone}'),
          const SizedBox(height: 6),
          Text(
            order.deliveryAddress,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text('Thanh toán: ${order.paymentMethod} (${order.paymentStatus})'),
          if (order.note.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Ghi chú: ${order.note}'),
          ],
          const SizedBox(height: 8),
          Text(
            'Tổng tiền: ${formatPrice(order.totalAmount)}',
            style: const TextStyle(
              color: Color(0xFFEF2A39),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Trạng thái: '),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  OrderStatusHelper.getText(order.orderStatus),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'Món đã đặt',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (order.items.isEmpty)
            const Text(
              'Chưa có chi tiết món',
              style: TextStyle(color: Colors.grey),
            )
          else
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(child: Text(item.productName)),
                    Text('x${item.quantity}'),
                    const SizedBox(width: 10),
                    Text(formatPrice(item.subtotal)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          if (order.cancelReason.trim().isNotEmpty) ...[
            Text(
              'Lý do hủy: ${order.cancelReason}',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              if (nextStatus.isNotEmpty)
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: onNext,
                    child: Text(OrderStatusHelper.getText(nextStatus)),
                  ),
                ),
              if (nextStatus.isNotEmpty &&
                  !order.isCompleted &&
                  !order.isCancelled)
                const SizedBox(width: 10),
              if (!order.isCompleted && !order.isCancelled)
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: onCancel,
                    child: const Text('Hủy đơn'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFFEF2A39),
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
