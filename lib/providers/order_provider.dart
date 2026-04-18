import 'package:flutter/material.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/order_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/cart_item_model.dart';

class OrderProvider extends ChangeNotifier {
  final List<OrderModel> _orders = [];

  List<OrderModel> get orders => _orders;

  void placeOrder(List<CartItem> cartItems, double totalAmount) {
    if (cartItems.isEmpty) return;

    final order = OrderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: List.from(cartItems),
      totalAmount: totalAmount,
      orderDate: DateTime.now(),
      status: 'Delivered',
    );

    _orders.insert(0, order);
    notifyListeners();
  }
}
