import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ct484tx_project_trangdc24v7x324/models/cart_item_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/product_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/providers/cart_provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/providers/product_provider.dart';
import 'package:ct484tx_project_trangdc24v7x324/features/product/widgets/food_card.dart';

class FoodAvailable extends StatelessWidget {
  final List<ProductModel> favoritedItems;
  final void Function(ProductModel) onFavoriteToggle;
  final String searchQuery;
  final String selectedCategory;

  const FoodAvailable({
    super.key,
    required this.favoritedItems,
    required this.onFavoriteToggle,
    required this.searchQuery,
    required this.selectedCategory,
  });

  String normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ả', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('ạ', 'a')
        .replaceAll('ă', 'a')
        .replaceAll('ắ', 'a')
        .replaceAll('ằ', 'a')
        .replaceAll('ẳ', 'a')
        .replaceAll('ẵ', 'a')
        .replaceAll('ặ', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ấ', 'a')
        .replaceAll('ầ', 'a')
        .replaceAll('ẩ', 'a')
        .replaceAll('ẫ', 'a')
        .replaceAll('ậ', 'a')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ẻ', 'e')
        .replaceAll('ẽ', 'e')
        .replaceAll('ẹ', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ế', 'e')
        .replaceAll('ề', 'e')
        .replaceAll('ể', 'e')
        .replaceAll('ễ', 'e')
        .replaceAll('ệ', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ì', 'i')
        .replaceAll('ỉ', 'i')
        .replaceAll('ĩ', 'i')
        .replaceAll('ị', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ò', 'o')
        .replaceAll('ỏ', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ọ', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('ố', 'o')
        .replaceAll('ồ', 'o')
        .replaceAll('ổ', 'o')
        .replaceAll('ỗ', 'o')
        .replaceAll('ộ', 'o')
        .replaceAll('ơ', 'o')
        .replaceAll('ớ', 'o')
        .replaceAll('ờ', 'o')
        .replaceAll('ở', 'o')
        .replaceAll('ỡ', 'o')
        .replaceAll('ợ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ù', 'u')
        .replaceAll('ủ', 'u')
        .replaceAll('ũ', 'u')
        .replaceAll('ụ', 'u')
        .replaceAll('ư', 'u')
        .replaceAll('ứ', 'u')
        .replaceAll('ừ', 'u')
        .replaceAll('ử', 'u')
        .replaceAll('ữ', 'u')
        .replaceAll('ự', 'u')
        .replaceAll('ý', 'y')
        .replaceAll('ỳ', 'y')
        .replaceAll('ỷ', 'y')
        .replaceAll('ỹ', 'y')
        .replaceAll('ỵ', 'y')
        .replaceAll('đ', 'd');
  }

  bool isFavorited(ProductModel product) {
    return favoritedItems.any((item) => item.id == product.id);
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final normalizedQuery = normalizeText(searchQuery.trim());

    if (productProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (productProvider.error != null) {
      return Center(
        child: Text(
          productProvider.error!,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.redAccent,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final filteredItems =
        productProvider.products.where((item) {
          final title = normalizeText(item.title);
          final subtitle = normalizeText(item.subtitle);
          final description = normalizeText(item.description);
          final category = normalizeText(item.category);

          final matchesSearch =
              normalizedQuery.isEmpty ||
              title.contains(normalizedQuery) ||
              subtitle.contains(normalizedQuery) ||
              description.contains(normalizedQuery) ||
              category.contains(normalizedQuery);

          final matchesCategory =
              selectedCategory == 'all' ||
              category == normalizeText(selectedCategory) ||
              category.contains(normalizeText(selectedCategory));

          return item.isAvailable && matchesSearch && matchesCategory;
        }).toList();

    if (filteredItems.isEmpty) {
      return const Center(
        child: Text(
          'Không tìm thấy món ăn',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
      itemCount: filteredItems.length,
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: filteredItems.length == 1 ? 1 : 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
        childAspectRatio: filteredItems.length == 1 ? 1.1 : 0.62,
      ),
      itemBuilder: (context, index) {
        final item = filteredItems[index];

        return FoodCard(
          product: item,
          isFavorited: isFavorited(item),
          onFavoriteToggle: () => onFavoriteToggle(item),
          onAddToCart: () {
            final cart = Provider.of<CartProvider>(context, listen: false);

            cart.addItem(
              CartItem(
                title: item.title,
                image: item.image,
                price: item.price,
                quantity: 1,
              ),
            );

            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${item.title} đã thêm vào giỏ hàng'),
                duration: const Duration(milliseconds: 900),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
  }
}
