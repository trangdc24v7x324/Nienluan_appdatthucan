class CartItem {
  final String productId;
  final String title;
  final String image;
  final double price;
  int quantity;

  final String categoryId;
  final String categoryTitle;
  final String categorySlug;

  CartItem({
    required this.productId,
    required this.title,
    required this.image,
    required this.price,
    this.quantity = 1,
    this.categoryId = '',
    this.categoryTitle = 'Khác',
    this.categorySlug = 'khac',
  });
}
