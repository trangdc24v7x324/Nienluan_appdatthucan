import 'dart:io';

import 'package:ct484tx_project_trangdc24v7x324/core/pocketbase_client.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/product_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/category_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ProductService {
  // ================= CATEGORY =================

  Future<List<CategoryModel>> getCategories() async {
    try {
      final records = await pb
          .collection('categories')
          .getFullList(sort: 'sortOrder', filter: 'isActive = true');

      return records.map((record) {
        final data = record.toJson();

        return CategoryModel(
          id: record.id,
          title: (data['title'] ?? '').toString(),
          slug: (data['slug'] ?? '').toString(),
          icon: (data['icon'] ?? '').toString(),
          sortOrder: ((data['sortOrder'] ?? 0) as num).toInt(),
          isActive: data['isActive'] ?? true,
        );
      }).toList();
    } catch (e) {
      debugPrint('GET CATEGORIES ERROR: $e');
      rethrow;
    }
  }

  // ================= PRODUCTS =================

  Future<List<ProductModel>> getProducts() async {
    try {
      final records = await pb
          .collection('products')
          .getFullList(sort: '-created', expand: 'category');

      return records.map((record) {
        final data = record.toJson();

        double parseDouble(dynamic value) {
          if (value == null) return 0;
          if (value is num) return value.toDouble();
          return double.tryParse(value.toString()) ?? 0;
        }

        bool parseBool(dynamic value) {
          if (value is bool) return value;
          if (value is num) return value != 0;
          final text = value.toString().toLowerCase().trim();
          return text == 'true' || text == '1';
        }

        final categoryData = _getCategoryData(record);

        return ProductModel(
          id: record.id,
          title: (data['title'] ?? '').toString(),
          subtitle: (data['subtitle'] ?? '').toString(),
          rating: parseDouble(data['rating']),
          image: _getImageUrl(record),
          description: (data['description'] ?? '').toString(),
          deliveryTime: (data['deliveryTime'] ?? '').toString(),
          price: parseDouble(data['price']),
          category: categoryData['slug']!, // 🔥 dùng slug
          isAvailable:
              data.containsKey('isAvailable')
                  ? parseBool(data['isAvailable'])
                  : true,
        );
      }).toList();
    } catch (e) {
      debugPrint('GET PRODUCTS ERROR: $e');
      rethrow;
    }
  }

  // ================= HELPER =================

  String _getImageUrl(dynamic record) {
    final fileName = record.getStringValue('image');
    if (fileName.isEmpty) return '';
    return '${pb.baseUrl}/api/files/products/${record.id}/$fileName';
  }

  Map<String, String> _getCategoryData(dynamic record) {
    final expand = record.expand;

    if (expand['category'] != null && expand['category']!.isNotEmpty) {
      final category = expand['category']!.first;

      return {
        'id': category.id,
        'title': category.getStringValue('title'),
        'slug': category.getStringValue('slug'),
      };
    }

    return {'id': '', 'title': 'Khác', 'slug': 'khac'};
  }

  // ================= CREATE / UPDATE =================

  Future<void> addProduct(ProductModel product, {File? imageFile}) async {
    try {
      final categoryId = await _findCategoryIdBySlug(product.category);

      final body = {
        'title': product.title,
        'subtitle': product.subtitle,
        'rating': product.rating,
        'description': product.description,
        'deliveryTime': product.deliveryTime,
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
      final categoryId = await _findCategoryIdBySlug(product.category);

      final body = {
        'title': product.title,
        'subtitle': product.subtitle,
        'rating': product.rating,
        'description': product.description,
        'deliveryTime': product.deliveryTime,
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

  Future<String?> _findCategoryIdBySlug(String slug) async {
    final records = await pb
        .collection('categories')
        .getFullList(filter: 'slug = "$slug"');

    if (records.isEmpty) return null;
    return records.first.id;
  }
}
