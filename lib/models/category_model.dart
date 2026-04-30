class CategoryModel {
  final String id;
  final String title;
  final String slug;
  final String icon;
  final int sortOrder;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.icon,
    required this.sortOrder,
    required this.isActive,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      sortOrder: ((json['sortOrder'] ?? 0) as num).toInt(),
      isActive: json['isActive'] ?? true,
    );
  }
}
