import 'dart:io';

import 'package:flutter/material.dart';
import 'package:CT466_project_trangdc24v7x324/models/category_model.dart';
import 'package:CT466_project_trangdc24v7x324/models/product_model.dart';
import 'package:CT466_project_trangdc24v7x324/services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  final List<ProductModel> _products = [];
  final List<CategoryModel> _categories = [];

  bool _isLoading = false;
  bool _isSaving = false;

  String _selectedCategorySlug = 'all';
  String _searchKeyword = '';

  String? _errorMessage;

  List<ProductModel> get products => List.unmodifiable(_products);

  List<CategoryModel> get categories => List.unmodifiable(_categories);

  bool get isLoading => _isLoading;

  bool get isSaving => _isSaving;

  String get selectedCategorySlug => _selectedCategorySlug;

  String get searchKeyword => _searchKeyword;

  String? get errorMessage => _errorMessage;

  List<ProductModel> get availableProducts {
    return _products.where((product) => product.isAvailable).toList();
  }

  List<ProductModel> get filteredProducts {
    Iterable<ProductModel> result = _products;

    if (_selectedCategorySlug != 'all') {
      result = result.where(
        (product) => product.categorySlug == _selectedCategorySlug,
      );
    }

    if (_searchKeyword.trim().isNotEmpty) {
      final keyword = _searchKeyword.toLowerCase().trim();

      result = result.where((product) {
        return product.title.toLowerCase().contains(keyword) ||
            product.subtitle.toLowerCase().contains(keyword) ||
            product.description.toLowerCase().contains(keyword) ||
            product.categoryTitle.toLowerCase().contains(keyword);
      });
    }

    return result.toList();
  }

  List<ProductModel> get filteredAvailableProducts {
    return filteredProducts.where((product) => product.isAvailable).toList();
  }

  Future<void> loadInitialData() async {
    _setLoading(true);
    _clearError();

    try {
      final results = await Future.wait([
        _productService.getCategories(),
        _productService.getProducts(),
      ]);

      _categories
        ..clear()
        ..addAll(results[0] as List<CategoryModel>);

      _products
        ..clear()
        ..addAll(results[1] as List<ProductModel>);
    } catch (e) {
      _setError('Không thể tải dữ liệu sản phẩm');
      debugPrint('loadInitialData error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCategories() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _productService.getCategories();

      _categories
        ..clear()
        ..addAll(result);
    } catch (e) {
      _setError('Không thể tải danh mục');
      debugPrint('loadCategories error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadProducts() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _productService.getProducts();

      _products
        ..clear()
        ..addAll(result);
    } catch (e) {
      _setError('Không thể tải sản phẩm');
      debugPrint('loadProducts error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<ProductModel?> getProductDetail(String productId) async {
    _setLoading(true);
    _clearError();

    try {
      return await _productService.getProductById(productId);
    } catch (e) {
      _setError('Không thể tải chi tiết sản phẩm');
      debugPrint('getProductDetail error: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addProduct(ProductModel product, {File? imageFile}) async {
    _isSaving = true;
    _clearError();
    notifyListeners();

    try {
      await _productService.addProduct(product, imageFile: imageFile);

      await loadProducts();

      return true;
    } catch (e) {
      _setError('Thêm sản phẩm thất bại');
      debugPrint('addProduct error: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateProduct(
    String id,
    ProductModel product, {
    File? imageFile,
  }) async {
    _isSaving = true;
    _clearError();
    notifyListeners();

    try {
      await _productService.updateProduct(id, product, imageFile: imageFile);

      await loadProducts();

      return true;
    } catch (e) {
      _setError('Cập nhật sản phẩm thất bại');
      debugPrint('updateProduct error: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(String id) async {
    _isSaving = true;
    _clearError();
    notifyListeners();

    try {
      await _productService.deleteProduct(id);

      _products.removeWhere((product) => product.id == id);

      return true;
    } catch (e) {
      _setError('Xóa sản phẩm thất bại');
      debugPrint('deleteProduct error: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void selectCategory(String slug) {
    _selectedCategorySlug = slug;
    notifyListeners();
  }

  void clearCategoryFilter() {
    _selectedCategorySlug = 'all';
    notifyListeners();
  }

  void searchProducts(String keyword) {
    _searchKeyword = keyword;
    notifyListeners();
  }

  void clearSearch() {
    _searchKeyword = '';
    notifyListeners();
  }

  ProductModel? findProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (_) {
      return null;
    }
  }

  CategoryModel? findCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (_) {
      return null;
    }
  }

  CategoryModel? findCategoryBySlug(String slug) {
    try {
      return _categories.firstWhere((category) => category.slug == slug);
    } catch (_) {
      return null;
    }
  }

  void clearData() {
    _products.clear();
    _categories.clear();
    _selectedCategorySlug = 'all';
    _searchKeyword = '';
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
