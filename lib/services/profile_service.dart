import 'dart:io';

import 'package:CT466_project_trangdc24v7x324/core/pocketbase_client.dart';
import 'package:CT466_project_trangdc24v7x324/models/address_model.dart';
import 'package:CT466_project_trangdc24v7x324/models/payment_method_model.dart';
import 'package:CT466_project_trangdc24v7x324/models/user_profile_model.dart';
import 'package:http/http.dart' as http;

class ProfileService {
  Future<UserProfileModel> fetchProfile() async {
    final authUser = pb.authStore.model;

    if (authUser == null) {
      throw Exception('Chưa đăng nhập');
    }

    try {
      final userRecord = await pb.collection('users').getOne(authUser.id);
      final userData = userRecord.data;

      final avatarUrl = _buildUserAvatarUrl(
        userId: userRecord.id,
        fileName: userData['avatar']?.toString(),
      );

      final addressRecords = await pb
          .collection('addresses')
          .getFullList(
            filter: 'user = "${userRecord.id}"',
            sort: '-isDefault,-created',
          );

      final addresses =
          addressRecords.map((record) {
            return AddressModel.fromJson({
              'id': record.id,
              ...record.data,
              'created': record.created,
              'updated': record.updated,
            });
          }).toList();

      final paymentRecords = await pb
          .collection('payment_methods')
          .getFullList(
            filter: 'user = "${userRecord.id}"',
            sort: '-isDefault,-created',
          );

      final paymentMethods =
          paymentRecords.map((record) {
            return PaymentMethodModel.fromJson({
              'id': record.id,
              ...record.data,
              'created': record.created,
              'updated': record.updated,
            });
          }).toList();

      return UserProfileModel.fromJson(
        {
          'id': userRecord.id,
          ...userRecord.data,
          'email': userRecord.getStringValue('email'),
          'created': userRecord.created,
          'updated': userRecord.updated,
        },
        avatarUrl: avatarUrl,
        addresses: addresses,
        paymentMethods: paymentMethods,
      );
    } catch (e) {
      print('FETCH PROFILE ERROR: $e');
      pb.authStore.clear();
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
    }
  }

  Future<void> updateGeneralInfo({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String gender,
    required DateTime? dateOfBirth,
  }) async {
    final authUser = pb.authStore.model;

    if (authUser == null) {
      throw Exception('Chưa đăng nhập');
    }

    await pb
        .collection('users')
        .update(
          authUser.id,
          body: {
            'fullName': fullName.trim(),
            'phoneNumber': phoneNumber.trim(),
            'gender': gender.trim(),
            'dateOfBirth': dateOfBirth?.toIso8601String(),
          },
        );

    await pb.collection('users').authRefresh();
  }

  Future<void> updateAvatar(File file) async {
    final authUser = pb.authStore.model;

    if (authUser == null) {
      throw Exception('Chưa đăng nhập');
    }

    await pb
        .collection('users')
        .update(
          authUser.id,
          files: [
            http.MultipartFile.fromBytes(
              'avatar',
              await file.readAsBytes(),
              filename: file.path.split('/').last,
            ),
          ],
        );

    await pb.collection('users').authRefresh();
  }

  Future<void> updateAddresses(List<AddressModel> addresses) async {
    final authUser = pb.authStore.model;

    if (authUser == null) {
      throw Exception('Chưa đăng nhập');
    }

    final oldRecords = await pb
        .collection('addresses')
        .getFullList(filter: 'user = "${authUser.id}"');

    for (final record in oldRecords) {
      await pb.collection('addresses').delete(record.id);
    }

    for (final address in addresses) {
      await pb
          .collection('addresses')
          .create(
            body: {
              'user': authUser.id,
              'receiverName': address.receiverName.trim(),
              'phoneNumber': address.phoneNumber.trim(),
              'addressLine': address.addressLine.trim(),
              'isDefault': address.isDefault,
              'note': address.note.trim(),
            },
          );
    }
  }

  Future<void> updatePaymentMethods(List<PaymentMethodModel> methods) async {
    final authUser = pb.authStore.model;

    if (authUser == null) {
      throw Exception('Chưa đăng nhập');
    }

    final oldRecords = await pb
        .collection('payment_methods')
        .getFullList(filter: 'user = "${authUser.id}"');

    for (final record in oldRecords) {
      await pb.collection('payment_methods').delete(record.id);
    }

    for (final method in methods) {
      await pb
          .collection('payment_methods')
          .create(
            body: {
              'user': authUser.id,
              'type': method.type.trim(),
              'displayName': method.displayName.trim(),
              'accountNumber': method.accountNumber.trim(),
              'provider': method.provider.trim(),
              'isDefault': method.isDefault,
            },
          );
    }
  }

  String _buildUserAvatarUrl({
    required String userId,
    required String? fileName,
  }) {
    if (fileName == null || fileName.trim().isEmpty) return '';

    return '${pb.baseUrl}/api/files/users/$userId/$fileName'
        '?ts=${DateTime.now().millisecondsSinceEpoch}';
  }
}
