import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/address_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/payment_method_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/user_profile_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/routes/app_routes.dart';
import 'package:ct484tx_project_trangdc24v7x324/services/auth_service.dart';
import 'package:ct484tx_project_trangdc24v7x324/services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  UserProfileModel? _profile;

  bool _isLoading = false;
  bool _isChangingPassword = false;
  bool _isEditingGeneralInfo = false;
  bool _isEditingAddress = false;
  bool _isEditingPaymentMethods = false;

  UserProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isChangingPassword => _isChangingPassword;
  bool get isEditingGeneralInfo => _isEditingGeneralInfo;
  bool get isEditingAddress => _isEditingAddress;
  bool get isEditingPaymentMethods => _isEditingPaymentMethods;

  void toggleAddressEdit() {
    _isEditingAddress = !_isEditingAddress;
    notifyListeners();
  }

  void toggleGeneralInfoEdit() {
    _isEditingGeneralInfo = !_isEditingGeneralInfo;
    notifyListeners();
  }

  void togglePaymentMethodsEdit() {
    _isEditingPaymentMethods = !_isEditingPaymentMethods;
    notifyListeners();
  }

  Future<void> loadProfile({bool forceReload = false}) async {
    if (_profile != null && !forceReload) return;

    if (!_authService.isLoggedIn) {
      _profile = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _profile = await _profileService.fetchProfile();
    } catch (e) {
      debugPrint('PROFILE ERROR: $e');

      _profile = null;
      await _authService.logout();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateGeneralInfo({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String gender,
    required DateTime? dateOfBirth,
  }) async {
    if (_profile == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _profileService.updateGeneralInfo(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );

      await loadProfile(forceReload: true);
      _isEditingGeneralInfo = false;
    } catch (e) {
      debugPrint('updateGeneralInfo error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAddresses(List<AddressModel> newAddresses) async {
    if (_profile == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _profileService.updateAddresses(newAddresses);
      await loadProfile(forceReload: true);
      _isEditingAddress = false;
    } catch (e) {
      debugPrint('updateAddresses error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePaymentMethods(
    List<PaymentMethodModel> updatedMethods,
  ) async {
    if (_profile == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _profileService.updatePaymentMethods(updatedMethods);
      await loadProfile(forceReload: true);
      _isEditingPaymentMethods = false;
    } catch (e) {
      debugPrint('updatePaymentMethods error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateUsername(String username) {
    if (_profile == null) return;

    _profile = _profile!.copyWith(username: username);
    notifyListeners();
  }

  Future<void> updateAvatar(File file) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _profileService.updateAvatar(file);
      await loadProfile(forceReload: true);
    } catch (e) {
      debugPrint('updateAvatar error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickAndUpdateAvatar() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      await updateAvatar(File(pickedFile.path));
    } catch (e) {
      debugPrint('pickAndUpdateAvatar error: $e');
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final oldPass = oldPassword.trim();
    final newPass = newPassword.trim();

    if (oldPass.isEmpty || newPass.isEmpty) {
      throw Exception('Vui lòng nhập đầy đủ mật khẩu');
    }

    if (newPass.length < 6) {
      throw Exception('Mật khẩu mới phải có ít nhất 6 ký tự');
    }

    if (oldPass == newPass) {
      throw Exception('Mật khẩu mới không được trùng mật khẩu cũ');
    }

    _isChangingPassword = true;
    notifyListeners();

    try {
      await _authService.changePassword(
        oldPassword: oldPass,
        newPassword: newPass,
      );
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _isChangingPassword = false;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    await _authService.logout();

    _profile = null;
    _isLoading = false;
    _isChangingPassword = false;
    _isEditingGeneralInfo = false;
    _isEditingAddress = false;
    _isEditingPaymentMethods = false;

    notifyListeners();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }
}
