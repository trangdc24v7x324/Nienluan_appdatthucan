class PaymentMethodModel {
  final String id;
  final String title;
  final String subtitle;
  final bool isDefault;
  final String type; // cash, momo, bank, visa...

  PaymentMethodModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.isDefault = false,
  });

  PaymentMethodModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    bool? isDefault,
    String? type,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

