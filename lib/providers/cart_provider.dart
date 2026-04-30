import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount {
    return _items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  void addItem(CartItem item) {
    final index = _items.indexWhere((e) => e.productId == item.productId);

    if (index >= 0) {
      _items[index].quantity += item.quantity;
    } else {
      _items.add(item);
    }

    notifyListeners();
  }

  void removeItem(CartItem item) {
    _items.removeWhere((e) => e.productId == item.productId);
    notifyListeners();
  }

  void increaseQty(CartItem item) {
    final index = _items.indexWhere((e) => e.productId == item.productId);

    if (index != -1) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decreaseQty(CartItem item) {
    final index = _items.indexWhere((e) => e.productId == item.productId);

    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }

      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  double get totalPrice {
    return _items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }
}
