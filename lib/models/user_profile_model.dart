import 'address_model.dart';
import 'payment_method_model.dart';

class UserProfileModel {
  final String? avatarUrl;

  final String fullName;
  final DateTime? dateOfBirth;
  final String gender;
  final String email;
  final String phoneNumber;

  final String username;
  final String passwordMasked;

  final List<AddressModel> addresses;
  final List<PaymentMethodModel> paymentMethods;

  UserProfileModel({
    required this.avatarUrl,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.email,
    required this.phoneNumber,
    required this.username,
    required this.passwordMasked,
    required this.addresses,
    required this.paymentMethods,
  });

  UserProfileModel copyWith({
    String? avatarUrl,
    String? fullName,
    DateTime? dateOfBirth,
    String? gender,
    String? email,
    String? phoneNumber,
    String? username,
    String? passwordMasked,
    List<AddressModel>? addresses,
    List<PaymentMethodModel>? paymentMethods,
  }) {
    return UserProfileModel(
      avatarUrl: avatarUrl ?? this.avatarUrl,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      username: username ?? this.username,
      passwordMasked: passwordMasked ?? this.passwordMasked,
      addresses: addresses ?? this.addresses,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }
}
