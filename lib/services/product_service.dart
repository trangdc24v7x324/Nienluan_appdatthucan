import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:ct484tx_project_trangdc24v7x324/core/pocketbase_client.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/product_model.dart';

class ProductService {
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

        return ProductModel(
          id: record.id,
          title: (data['name'] ?? data['title'] ?? '').toString(),
          subtitle: (data['subtitle'] ?? '').toString(),
          rating: parseDouble(data['rating']),
          image: _getImageUrl(record),
          description: (data['description'] ?? '').toString(),
          deliveryTime: (data['deliveryTime'] ?? '').toString(),
          price: parseDouble(data['price']),
          category: _getCategoryKey(record),
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

  String _getImageUrl(dynamic record) {
    final fileName = record.getStringValue('image');
    if (fileName.isEmpty) return '';
    return '${pb.baseUrl}/api/files/products/${record.id}/$fileName';
  }

  String _normalizeCategory(String value) {
    final raw = value.toLowerCase().trim();

    if (raw == 'combo' || raw == 'combos') return 'combos';
    if (raw == 'food' || raw == 'món ăn' || raw == 'mon an') return 'food';
    if (raw == 'drink' || raw == 'nước uống' || raw == 'nuoc uong') {
      return 'drink';
    }

    return raw;
  }

  String _getCategoryKey(dynamic record) {
    final expand = record.expand;

    if (expand['category'] != null && expand['category']!.isNotEmpty) {
      final categoryRecord = expand['category']!.first;
      final title = categoryRecord.getStringValue('title');
      if (title.isNotEmpty) {
        return _normalizeCategory(title);
      }
    }

    final rawCategory = record.getStringValue('category');
    return _normalizeCategory(rawCategory);
  }

  Future<String?> _findCategoryIdByKey(String categoryKey) async {
    final normalized = _normalizeCategory(categoryKey);
    final records = await pb.collection('categories').getFullList();

    for (final record in records) {
      final title = record.getStringValue('title').toLowerCase().trim();
      if (_normalizeCategory(title) == normalized) {
        return record.id;
      }
    }

    return null;
  }

  Future<void> addProduct(ProductModel product, {File? imageFile}) async {
    try {
      final categoryId = await _findCategoryIdByKey(product.category);

      if (categoryId == null) {
        throw Exception('Không tìm thấy category: ${product.category}');
      }

      final body = {
        'name': product.title,
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
      final categoryId = await _findCategoryIdByKey(product.category);

      if (categoryId == null) {
        throw Exception('Không tìm thấy category: ${product.category}');
      }

      final body = {
        'name': product.title,
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
}
