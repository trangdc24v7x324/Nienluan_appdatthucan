import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:ct484tx_project_trangdc24v7x324/core/pocketbase_client.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/address_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/payment_method_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/user_profile_model.dart';

class ProfileService {
  Future<void> updateAvatar(File file) async {
    final user = pb.authStore.model;

    if (user == null) {
      throw Exception('Chưa đăng nhập');
    }

    await pb
        .collection('users')
        .update(
          user.id,
          files: [
            http.MultipartFile.fromBytes(
              'avatar',
              await file.readAsBytes(),
              filename: file.path.split('/').last,
            ),
          ],
        );
  }

  Future<UserProfileModel> fetchProfile() async {
    final user = pb.authStore.model;

    if (user == null) {
      throw Exception('Chưa đăng nhập');
    }

    final userData = user.data;

    final avatarFile = userData['avatar'];
    String? avatarUrl;

    if (avatarFile != null && avatarFile.toString().trim().isNotEmpty) {
      avatarUrl = '${pb.baseUrl}/api/files/users/${user.id}/$avatarFile';
    }

    final addressResult = await pb
        .collection('addresses')
        .getFullList(filter: 'user = "${user.id}"', sort: '-created');

    final addresses =
        addressResult.map((record) {
          final data = record.data;

          return AddressModel(
            id: record.id,
            receiverName: (data['receiverName'] ?? '').toString(),
            phoneNumber: (data['phoneNumber'] ?? '').toString(),
            fullAddress: (data['addressLine'] ?? '').toString(),
            isDefault: data['isDefault'] ?? false,
          );
        }).toList();

    final paymentResult = await pb
        .collection('payment_methods')
        .getFullList(filter: 'user = "${user.id}"', sort: '-created');

    final paymentMethods =
        paymentResult.map((record) {
          final data = record.data;

          final type = (data['type'] ?? '').toString();
          final displayName = (data['displayName'] ?? '').toString();
          final provider = (data['provider'] ?? '').toString();
          final accountNumber = (data['accountNumber'] ?? '').toString();

          String subtitle = '';

          if (provider.isNotEmpty && accountNumber.isNotEmpty) {
            subtitle = '$provider - $accountNumber';
          } else if (provider.isNotEmpty) {
            subtitle = provider;
          } else if (accountNumber.isNotEmpty) {
            subtitle = accountNumber;
          }

          return PaymentMethodModel(
            id: record.id,
            title: displayName,
            subtitle: subtitle,
            type: type,
            isDefault: data['isDefault'] ?? false,
          );
        }).toList();

    DateTime? parsedDateOfBirth;
    final rawDateOfBirth = userData['dateOfBirth'];

    if (rawDateOfBirth != null && rawDateOfBirth.toString().trim().isNotEmpty) {
      try {
        parsedDateOfBirth = DateTime.parse(rawDateOfBirth.toString());
      } catch (_) {
        parsedDateOfBirth = null;
      }
    }

    return UserProfileModel(
      fullName: (userData['fullName'] ?? '').toString(),
      dateOfBirth: parsedDateOfBirth,
      gender: (userData['gender'] ?? '').toString(),
      email: user.getStringValue('email'),
      phoneNumber: (userData['phoneNumber'] ?? '').toString(),
      username: (userData['fullName'] ?? '').toString(),
      passwordMasked: '******',
      avatarUrl: avatarUrl,
      addresses: addresses,
      paymentMethods: paymentMethods,
    );
  }

  Future<void> updateGeneralInfo({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String gender,
    required DateTime? dateOfBirth,
  }) async {
    final user = pb.authStore.model;

    if (user == null) {
      throw Exception('Chưa đăng nhập');
    }

    await pb
        .collection('users')
        .update(
          user.id,
          body: {
            'fullName': fullName,
            'phoneNumber': phoneNumber,
            'gender': gender,
            'dateOfBirth': dateOfBirth?.toIso8601String(),
          },
        );
  }

  Future<void> updateAddresses(List<AddressModel> newAddresses) async {
    final user = pb.authStore.model;

    if (user == null) {
      throw Exception('Chưa đăng nhập');
    }

    final oldAddresses = await pb
        .collection('addresses')
        .getFullList(filter: 'user = "${user.id}"');

    for (final item in oldAddresses) {
      await pb.collection('addresses').delete(item.id);
    }

    for (final address in newAddresses) {
      await pb
          .collection('addresses')
          .create(
            body: {
              'user': user.id,
              'receiverName': address.receiverName,
              'phoneNumber': address.phoneNumber,
              'addressLine': address.fullAddress,
              'isDefault': address.isDefault,
              'note': '',
            },
          );
    }
  }
}
