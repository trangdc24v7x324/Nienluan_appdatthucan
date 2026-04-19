class ProductModel {
  final String id;
  final String title;
  final String subtitle;
  final double rating;
  final String image;
  final String description;
  final String deliveryTime;
  final double price;
  final String category;
  final bool isAvailable;

  ProductModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.image,
    required this.description,
    required this.deliveryTime,
    required this.price,
    required this.category,
    required this.isAvailable,
  });

  static String normalizeCategory(dynamic value) {
    final raw = value?.toString().toLowerCase().trim() ?? '';

    if (raw == 'combo' || raw == 'combos') return 'combos';
    if (raw == 'food' || raw == 'món ăn' || raw == 'mon an') return 'food';
    if (raw == 'drink' || raw == 'nước uống' || raw == 'nuoc uong')
      return 'drink';

    return raw;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      title: json['name']?.toString() ?? json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      image: json['image']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      deliveryTime: json['deliveryTime']?.toString() ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: normalizeCategory(json['category']),
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': title,
      'subtitle': subtitle,
      'rating': rating,
      'image': image,
      'description': description,
      'deliveryTime': deliveryTime,
      'price': price,
      'category': category,
      'isAvailable': isAvailable,
    };
  }

  ProductModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    double? rating,
    String? image,
    String? description,
    String? deliveryTime,
    double? price,
    String? category,
    bool? isAvailable,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      rating: rating ?? this.rating,
      image: image ?? this.image,
      description: description ?? this.description,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      price: price ?? this.price,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
