import 'package:flutter/material.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/cart_item_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/order_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  final List<OrderModel> _orders = [];
  bool _isLoading = false;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _orderService.fetchMyOrders();

      _orders
        ..clear()
        ..addAll(result);
    } catch (e) {
      debugPrint('loadOrders error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadAllOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _orderService.fetchAllOrders();

      _orders
        ..clear()
        ..addAll(result);
    } catch (e) {
      debugPrint('loadAllOrders error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> placeOrder(
    List<CartItem> cartItems,
    double totalAmount, {
    required String receiverName,
    required String receiverPhone,
    required String address,
    required String paymentMethod,
    String note = '',
  }) async {
    if (cartItems.isEmpty) return;

    await _orderService.createOrder(
      items: cartItems,
      totalAmount: totalAmount,
      receiverName: receiverName,
      receiverPhone: receiverPhone,
      deliveryAddress: address,
      paymentMethod: paymentMethod,
      note: note,
    );

    await loadOrders();
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    bool reloadAll = true,
  }) async {
    await _orderService.updateOrderStatus(orderId: orderId, status: status);

    if (reloadAll) {
      await loadAllOrders();
    } else {
      await loadOrders();
    }
  }
  int get pendingOrderCount {
    return _orders.where((order) {
      return order.status == 'placed' ||
          order.status == 'confirmed' ||
          order.status == 'preparing' ||
          order.status == 'delivering';
    }).length;
  }

  int get completedOrderCount {
    return _orders.where((order) => order.status == 'completed').length;
  }

  double get completedRevenue {
    return _orders
        .where((order) => order.status == 'completed')
        .fold(0, (sum, order) => sum + order.totalAmount);
  }
}
