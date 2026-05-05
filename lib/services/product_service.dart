import 'dart:io';

import 'package:CT466_project_trangdc24v7x324/core/pocketbase_client.dart';
import 'package:CT466_project_trangdc24v7x324/models/category_model.dart';
import 'package:CT466_project_trangdc24v7x324/models/product_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ProductService {
  Future<List<CategoryModel>> getCategories() async {
    try {
      final records = await pb
          .collection('categories')
          .getFullList(sort: 'sortOrder', filter: 'isActive = true');

      return records.map((record) {
        return CategoryModel.fromJson({
          'id': record.id,
          ...record.data,
          'created': record.created,
          'updated': record.updated,
        });
      }).toList();
    } catch (e) {
      debugPrint('GET CATEGORIES ERROR: $e');
      rethrow;
    }
  }

  Future<List<ProductModel>> getProducts() async {
    try {
      final records = await pb
          .collection('products')
          .getFullList(sort: '-created', expand: 'category');

      return records.map(_mapProductRecord).toList();
    } catch (e) {
      debugPrint('GET PRODUCTS ERROR: $e');
      rethrow;
    }
  }

  Future<ProductModel> getProductById(String id) async {
    try {
      final record = await pb
          .collection('products')
          .getOne(id, expand: 'category');

      return _mapProductRecord(record);
    } catch (e) {
      debugPrint('GET PRODUCT BY ID ERROR: $e');
      rethrow;
    }
  }

  Future<void> addProduct(ProductModel product, {File? imageFile}) async {
    try {
      final categoryId = await _resolveCategoryId(product);

      final body = {
        'title': product.title.trim(),
        'subtitle': product.subtitle.trim(),
        'rating': product.rating,
        'description': product.description.trim(),
        'deliveryTime': product.deliveryTime.trim(),
        'price': product.price,
        'category': categoryId,
        'isAvailable': product.isAvailable,
      };

      if (imageFile != null) {
        await pb
            .collection('products')
            .create(
              body: body,
              files: [
                http.MultipartFile.fromBytes(
                  'image',
                  await imageFile.readAsBytes(),
                  filename: imageFile.path.split('/').last,
                ),
              ],
            );
      } else {
        await pb.collection('products').create(body: body);
      }
    } catch (e) {
      debugPrint('ADD PRODUCT ERROR: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(
    String id,
    ProductModel product, {
    File? imageFile,
  }) async {
    try {
      final categoryId = await _resolveCategoryId(product);

      final body = {
        'title': product.title.trim(),
        'subtitle': product.subtitle.trim(),
        'rating': product.rating,
        'description': product.description.trim(),
        'deliveryTime': product.deliveryTime.trim(),
        'price': product.price,
        'category': categoryId,
        'isAvailable': product.isAvailable,
      };

      if (imageFile != null) {
        await pb
            .collection('products')
            .update(
              id,
              body: body,
              files: [
                http.MultipartFile.fromBytes(
                  'image',
                  await imageFile.readAsBytes(),
                  filename: imageFile.path.split('/').last,
                ),
              ],
            );
      } else {
        await pb.collection('products').update(id, body: body);
      }
    } catch (e) {
      debugPrint('UPDATE PRODUCT ERROR: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await pb.collection('products').delete(id);
    } catch (e) {
      debugPrint('DELETE PRODUCT ERROR: $e');
      rethrow;
    }
  }

  ProductModel _mapProductRecord(dynamic record) {
    final categoryData = _getCategoryData(record);

    return ProductModel.fromJson({
      'id': record.id,
      ...record.data,
      'image': _buildProductImageUrl(record),
      'category': categoryData['id'],
      'categoryTitle': categoryData['title'],
      'categorySlug': categoryData['slug'],
      'created': record.created,
      'updated': record.updated,
    });
  }

  Map<String, String> _getCategoryData(dynamic record) {
    try {
      final expand = record.expand;

      if (expand['category'] != null && expand['category']!.isNotEmpty) {
        final category = expand['category']!.first;

        return {
          'id': category.id,
          'title': category.getStringValue('title'),
          'slug': category.getStringValue('slug'),
        };
      }
    } catch (_) {}

    final rawCategory = record.data['category']?.toString() ?? '';

    return {'id': rawCategory, 'title': 'Khác', 'slug': 'khac'};
  }

  String _buildProductImageUrl(dynamic record) {
    final fileName = record.getStringValue('image');

    if (fileName.isEmpty) return '';

    return '${pb.baseUrl}/api/files/products/${record.id}/$fileName';
  }

  Future<String?> _resolveCategoryId(ProductModel product) async {
    if (product.categoryId.isNotEmpty) {
      return product.categoryId;
    }

    if (product.categorySlug.isNotEmpty && product.categorySlug != 'khac') {
      final records = await pb
          .collection('categories')
          .getFullList(filter: 'slug = "${product.categorySlug}"');

      if (records.isNotEmpty) {
        return records.first.id;
      }
    }

    return null;
  }
}
