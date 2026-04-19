import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/product_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _productService.getProducts();
    } catch (e) {
      _error = 'Không tải được sản phẩm';
      debugPrint('fetchProducts error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProduct(ProductModel product, {File? imageFile}) async {
    try {
      await _productService.addProduct(product, imageFile: imageFile);
      await fetchProducts();
    } catch (e) {
      _error = 'Không thêm được sản phẩm';
      debugPrint('addProduct error: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProduct(
    String id,
    ProductModel product, {
    File? imageFile,
  }) async {
    try {
      await _productService.updateProduct(id, product, imageFile: imageFile);
      await fetchProducts();
    } catch (e) {
      _error = 'Không cập nhật được sản phẩm';
      debugPrint('updateProduct error: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _productService.deleteProduct(id);
      _products.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Không xóa được sản phẩm';
      debugPrint('deleteProduct error: $e');
      notifyListeners();
      rethrow;
    }
  }
}
