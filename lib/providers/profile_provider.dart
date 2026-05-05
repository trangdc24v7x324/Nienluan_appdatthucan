import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:CT466_project_trangdc24v7x324/models/address_model.dart';
import 'package:CT466_project_trangdc24v7x324/models/payment_method_model.dart';
import 'package:CT466_project_trangdc24v7x324/models/user_profile_model.dart';
import 'package:CT466_project_trangdc24v7x324/routes/app_routes.dart';
import 'package:CT466_project_trangdc24v7x324/services/auth_service.dart';
import 'package:CT466_project_trangdc24v7x324/services/profile_service.dart';

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

  String? _errorMessage;

  UserProfileModel? get profile => _profile;

  bool get isLoading => _isLoading;

  bool get isChangingPassword => _isChangingPassword;

  bool get isEditingGeneralInfo => _isEditingGeneralInfo;

  bool get isEditingAddress => _isEditingAddress;

  bool get isEditingPaymentMethods => _isEditingPaymentMethods;

  String? get errorMessage => _errorMessage;

  bool get hasProfile => _profile != null;

  List<AddressModel> get addresses => _profile?.addresses ?? [];

  List<PaymentMethodModel> get paymentMethods {
    return _profile?.paymentMethods ?? [];
  }

  AddressModel? get defaultAddress {
    try {
      return addresses.firstWhere((address) => address.isDefault);
    } catch (_) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }

  PaymentMethodModel? get defaultPaymentMethod {
    try {
      return paymentMethods.firstWhere((method) => method.isDefault);
    } catch (_) {
      return paymentMethods.isNotEmpty ? paymentMethods.first : null;
    }
  }

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

    _setLoading(true);
    _clearError();

    try {
      _profile = await _profileService.fetchProfile();
    } catch (e) {
      _profile = null;
      await _authService.logout();
      _setError('Không thể tải thông tin tài khoản');
      debugPrint('PROFILE ERROR: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateGeneralInfo({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String gender,
    required DateTime? dateOfBirth,
  }) async {
    if (_profile == null) return false;

    _setLoading(true);
    _clearError();

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

      return true;
    } catch (e) {
      _setError('Cập nhật thông tin thất bại');
      debugPrint('updateGeneralInfo error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateAddresses(List<AddressModel> newAddresses) async {
    if (_profile == null) return false;

    _setLoading(true);
    _clearError();

    try {
      await _profileService.updateAddresses(newAddresses);
      await loadProfile(forceReload: true);

      _isEditingAddress = false;

      return true;
    } catch (e) {
      _setError('Cập nhật địa chỉ thất bại');
      debugPrint('updateAddresses error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updatePaymentMethods(
    List<PaymentMethodModel> updatedMethods,
  ) async {
    if (_profile == null) return false;

    _setLoading(true);
    _clearError();

    try {
      await _profileService.updatePaymentMethods(updatedMethods);
      await loadProfile(forceReload: true);

      _isEditingPaymentMethods = false;

      return true;
    } catch (e) {
      _setError('Cập nhật phương thức thanh toán thất bại');
      debugPrint('updatePaymentMethods error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateAvatar(File file) async {
    _setLoading(true);
    _clearError();

    try {
      await _profileService.updateAvatar(file);
      await loadProfile(forceReload: true);

      return true;
    } catch (e) {
      _setError('Cập nhật ảnh đại diện thất bại');
      debugPrint('updateAvatar error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> pickAndUpdateAvatar() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) return false;

      return await updateAvatar(File(pickedFile.path));
    } catch (e) {
      _setError('Không thể chọn ảnh');
      debugPrint('pickAndUpdateAvatar error: $e');
      return false;
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
    _clearError();
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
    _errorMessage = null;

    notifyListeners();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  void clearProfile() {
    _profile = null;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
