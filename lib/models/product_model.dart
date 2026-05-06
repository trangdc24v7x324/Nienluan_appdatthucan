class ProductModel {
  final String id;
  final String title;
  final String subtitle;
  final double rating;
  final String image;
  final String description;
  final String deliveryTime;
  final double price;

  final String categoryId;

  final String categoryTitle;
  final String categorySlug;

  final bool isAvailable;
  final DateTime? created;
  final DateTime? updated;

  const ProductModel({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.rating = 0,
    this.image = '',
    this.description = '',
    this.deliveryTime = '',
    this.price = 0,
    this.categoryId = '',
    this.categoryTitle = 'Khác',
    this.categorySlug = 'khac',
    this.isAvailable = true,
    this.created,
    this.updated,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      rating: _toDouble(json['rating']),
      image: json['image']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      deliveryTime: json['deliveryTime']?.toString() ?? '',
      price: _toDouble(json['price']),
      categoryId: json['category']?.toString() ?? '',
      categoryTitle: json['categoryTitle']?.toString() ?? 'Khác',
      categorySlug: json['categorySlug']?.toString() ?? 'khac',
      isAvailable: json['isAvailable'] != false,
      created: DateTime.tryParse(json['created']?.toString() ?? ''),
      updated: DateTime.tryParse(json['updated']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'rating': rating,
      'image': image,
      'description': description,
      'deliveryTime': deliveryTime,
      'price': price,
      'category': categoryId,
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
    String? categoryId,
    String? categoryTitle,
    String? categorySlug,
    bool? isAvailable,
    DateTime? created,
    DateTime? updated,
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
      categoryId: categoryId ?? this.categoryId,
      categoryTitle: categoryTitle ?? this.categoryTitle,
      categorySlug: categorySlug ?? this.categorySlug,
      isAvailable: isAvailable ?? this.isAvailable,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
