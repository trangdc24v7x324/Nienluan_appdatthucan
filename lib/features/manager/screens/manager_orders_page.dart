import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ct484tx_project_trangdc24v7x324/providers/order_provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/utils/order_status_helper.dart';

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
    Future.microtask(() {
      context.read<OrderProvider>().loadAllOrders();
    });
  }

  Future<void> _refresh() async {
    await context.read<OrderProvider>().loadAllOrders();
  }

  String getNextStatus(String status) {
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

  List<dynamic> filterOrders(List<dynamic> orders) {
    if (selectedFilter == 'all') return orders;

    if (selectedFilter == 'processing') {
      return orders.where((order) {
        return order.status == 'placed' ||
            order.status == 'confirmed' ||
            order.status == 'preparing' ||
            order.status == 'delivering';
      }).toList();
    }

    if (selectedFilter == 'completed') {
      return orders.where((order) => order.status == 'completed').toList();
    }

    if (selectedFilter == 'cancelled') {
      return orders.where((order) => order.status == 'cancelled').toList();
    }

    return orders.where((order) => order.status == selectedFilter).toList();
  }

  String formatPrice(double price) {
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final orders = filterOrders(provider.orders);

    return Scaffold(
      backgroundColor: const Color(0xFFEF2A39),
      body: Column(
        children: [
          const _ManagerHeader(title: 'Quản lý đơn hàng'),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child:
                  provider.isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFEF2A39),
                        ),
                      )
                      : RefreshIndicator(
                        onRefresh: _refresh,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final horizontalPadding =
                                constraints.maxWidth >= 700 ? 24.0 : 16.0;

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
                                    constraints: const BoxConstraints(
                                      maxWidth: 760,
                                    ),
                                    child: Column(
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
                                            final statusColor =
                                                OrderStatusHelper.getColor(
                                                  order.status,
                                                );
                                            final nextStatus = getNextStatus(
                                              order.status,
                                            );

                                            return _OrderCard(
                                              order: order,
                                              statusColor: statusColor,
                                              nextStatus: nextStatus,
                                              onNext: () async {
                                                await provider
                                                    .updateOrderStatus(
                                                      orderId: order.id,
                                                      status: nextStatus,
                                                    );
                                              },
                                              onCancel: () async {
                                                await provider
                                                    .updateOrderStatus(
                                                      orderId: order.id,
                                                      status: 'cancelled',
                                                    );
                                              },
                                              formatPrice: formatPrice,
                                            );
                                          }),
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
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Wrap(
      spacing: 8,
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

class _ManagerHeader extends StatelessWidget {
  final String title;

  const _ManagerHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: const Color(0xFFEF2A39),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final dynamic order;
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
          Text(order.address, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text('Thanh toán: ${order.paymentMethod}'),
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
                  OrderStatusHelper.getText(order.status),
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
          ...order.items.map(
            (item) => Row(
              children: [
                Expanded(child: Text(item.title)),
                Text('x${item.quantity}'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (nextStatus.isNotEmpty)
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: onNext,
                    child: Text(OrderStatusHelper.getText(nextStatus)),
                  ),
                ),
              if (nextStatus.isNotEmpty) const SizedBox(width: 10),
              if (order.status != 'completed' && order.status != 'cancelled')
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
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
