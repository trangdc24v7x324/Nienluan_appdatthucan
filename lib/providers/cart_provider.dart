import 'package:flutter/material.dart';
import 'package:CT466_project_trangdc24v7x324/models/cart_item_model.dart';
import 'package:CT466_project_trangdc24v7x324/models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  int get itemCount {
    return _items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  int get uniqueItemCount => _items.length;

  double get totalPrice {
    return _items.fold<double>(0, (sum, item) => sum + item.subtotal);
  }

  bool containsProduct(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  CartItemModel? getItemByProductId(String productId) {
    try {
      return _items.firstWhere((item) => item.productId == productId);
    } catch (_) {
      return null;
    }
  }

  void addProduct(ProductModel product, {int quantity = 1}) {
    final item = CartItemModel.fromProduct(product, quantity: quantity);

    addItem(item);
  }

  void addItem(CartItemModel item) {
    final index = _items.indexWhere(
      (element) => element.productId == item.productId,
    );

    if (index >= 0) {
      final currentItem = _items[index];

      _items[index] = currentItem.copyWith(
        quantity: currentItem.quantity + item.quantity,
      );
    } else {
      _items.add(item);
    }

    notifyListeners();
  }

  void removeItem(CartItemModel item) {
    removeByProductId(item.productId);
  }

  void removeByProductId(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void increaseQty(CartItemModel item) {
    increaseQuantity(item.productId);
  }

  void increaseQuantity(String productId) {
    final index = _items.indexWhere((item) => item.productId == productId);

    if (index == -1) return;

    final currentItem = _items[index];

    _items[index] = currentItem.copyWith(quantity: currentItem.quantity + 1);

    notifyListeners();
  }

  void decreaseQty(CartItemModel item) {
    decreaseQuantity(item.productId);
  }

  void decreaseQuantity(String productId) {
    final index = _items.indexWhere((item) => item.productId == productId);

    if (index == -1) return;

    final currentItem = _items[index];

    if (currentItem.quantity > 1) {
      _items[index] = currentItem.copyWith(quantity: currentItem.quantity - 1);
    } else {
      _items.removeAt(index);
    }

    notifyListeners();
  }

  void updateQuantity({required String productId, required int quantity}) {
    final index = _items.indexWhere((item) => item.productId == productId);

    if (index == -1) return;

    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: quantity);
    }

    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
