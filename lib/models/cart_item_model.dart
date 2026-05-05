import 'product_model.dart';

// dùng cho giỏ hàng, không dùng cho lịch sử đơn hàng
class CartItemModel {
  final String productId;
  final String title;
  final String image;
  final double price;
  final int quantity;

  final String categoryId;
  final String categoryTitle;
  final String categorySlug;

  const CartItemModel({
    required this.productId,
    required this.title,
    this.image = '',
    required this.price,
    this.quantity = 1,
    this.categoryId = '',
    this.categoryTitle = 'Khác',
    this.categorySlug = 'khac',
  });

  double get subtotal => price * quantity;

  factory CartItemModel.fromProduct(ProductModel product, {int quantity = 1}) {
    return CartItemModel(
      productId: product.id,
      title: product.title,
      image: product.image,
      price: product.price,
      quantity: quantity,
      categoryId: product.categoryId,
      categoryTitle: product.categoryTitle,
      categorySlug: product.categorySlug,
    );
  }

  CartItemModel copyWith({
    String? productId,
    String? title,
    String? image,
    double? price,
    int? quantity,
    String? categoryId,
    String? categoryTitle,
    String? categorySlug,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      title: title ?? this.title,
      image: image ?? this.image,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      categoryId: categoryId ?? this.categoryId,
      categoryTitle: categoryTitle ?? this.categoryTitle,
      categorySlug: categorySlug ?? this.categorySlug,
    );
  }
}
