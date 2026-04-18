class AddressModel {
  final String id;
  final String receiverName;
  final String phoneNumber;
  final String fullAddress;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.receiverName,
    required this.phoneNumber,
    required this.fullAddress,
    this.isDefault = false,
  });

  AddressModel copyWith({
    String? id,
    String? receiverName,
    String? phoneNumber,
    String? fullAddress,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      receiverName: receiverName ?? this.receiverName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullAddress: fullAddress ?? this.fullAddress,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
