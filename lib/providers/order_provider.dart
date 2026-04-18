import 'package:flutter/material.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/order_item.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/cart_item_model.dart';

class OrderProvider extends ChangeNotifier {
  final List<OrderItem> _orders = [];

  List<OrderItem> get orders => _orders;

  void placeOrder(List<CartItem> cartItems, double totalAmount) {
    if (cartItems.isEmpty) return;

    final order = OrderItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: cartItems
          .map(
            (item) => {
              'title': item.title,
              'image': item.image,
              'price': item.price,
              'quantity': item.quantity,
            },
          )
          .toList(),
      totalAmount: totalAmount,
      orderDate: DateTime.now(),
      status: 'Delivered',
    );

    _orders.insert(0, order);
    notifyListeners();
  }
}
