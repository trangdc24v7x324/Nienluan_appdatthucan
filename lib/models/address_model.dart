class AddressModel {
  final String id;
  final String userId;
  final String receiverName;
  final String phoneNumber;
  final String addressLine;
  final bool isDefault;
  final String note;
  final DateTime? created;
  final DateTime? updated;

  const AddressModel({
    required this.id,
    required this.userId,
    required this.receiverName,
    required this.phoneNumber,
    required this.addressLine,
    this.isDefault = false,
    this.note = '',
    this.created,
    this.updated,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString() ?? '',
      userId: json['user']?.toString() ?? '',
      receiverName: json['receiverName']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      addressLine: json['addressLine']?.toString() ?? '',
      isDefault: json['isDefault'] == true,
      note: json['note']?.toString() ?? '',
      created: DateTime.tryParse(json['created']?.toString() ?? ''),
      updated: DateTime.tryParse(json['updated']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'receiverName': receiverName,
      'phoneNumber': phoneNumber,
      'addressLine': addressLine,
      'isDefault': isDefault,
      'note': note,
    };
  }

  AddressModel copyWith({
    String? id,
    String? userId,
    String? receiverName,
    String? phoneNumber,
    String? addressLine,
    bool? isDefault,
    String? note,
    DateTime? created,
    DateTime? updated,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      receiverName: receiverName ?? this.receiverName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addressLine: addressLine ?? this.addressLine,
      isDefault: isDefault ?? this.isDefault,
      note: note ?? this.note,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }
}
