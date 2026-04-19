import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/address_model.dart';
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
  bool _isEditingGeneralInfo = false;
  bool _isEditingAddress = false;

  UserProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isEditingGeneralInfo => _isEditingGeneralInfo;
  bool get isEditingAddress => _isEditingAddress;

  void toggleAddressEdit() {
    _isEditingAddress = !_isEditingAddress;
    notifyListeners();
  }

  void toggleGeneralInfoEdit() {
    _isEditingGeneralInfo = !_isEditingGeneralInfo;
    notifyListeners();
  }

  Future<void> loadProfile({bool forceReload = false}) async {
    if (_profile != null && !forceReload) return;

    _isLoading = true;
    notifyListeners();

    try {
      _profile = await _profileService.fetchProfile();
    } catch (e) {
      debugPrint('PROFILE ERROR: $e');
      _profile = null;
    }

    _isLoading = false;
    notifyListeners();
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
    }

    _isLoading = false;
    notifyListeners();
  }

  void updateUsername(String username) {
    if (_profile == null) return;

    _profile = _profile!.copyWith(username: username);
    notifyListeners();
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
    }

    _isLoading = false;
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
    }

    _isLoading = false;
    notifyListeners();
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

  void logout(BuildContext context) {
    _authService.logout();

    _profile = null;
    _isEditingGeneralInfo = false;
    _isEditingAddress = false;

    notifyListeners();

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }
}
