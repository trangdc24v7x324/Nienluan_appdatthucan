import 'package:flutter/material.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/user_profile_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/routes/app_routes.dart';
import 'package:ct484tx_project_trangdc24v7x324/services/profile_service.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/address_model.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  UserProfileModel? _profile;
  bool _isLoading = false;

  bool _isEditingGeneralInfo = false;

  UserProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isEditingGeneralInfo => _isEditingGeneralInfo;

  bool _isEditingAddress = false;
  bool get isEditingAddress => _isEditingAddress;

  void toggleAddressEdit() {
    _isEditingAddress = !_isEditingAddress;
    notifyListeners();
  }

  Future<void> loadProfile() async {
    if (_profile != null) return;

    _isLoading = true;
    notifyListeners();

    _profile = await _profileService.fetchProfile();

    _isLoading = false;
    notifyListeners();
  }

  void toggleGeneralInfoEdit() {
    _isEditingGeneralInfo = !_isEditingGeneralInfo;
    notifyListeners();
  }

  void updateGeneralInfo({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String gender,
    required DateTime? dateOfBirth,
  }) {
    if (_profile == null) return;

    _profile = _profile!.copyWith(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      gender: gender,
      dateOfBirth: dateOfBirth,
    );

    _isEditingGeneralInfo = false;
    notifyListeners();
  }

  void updateUsername(String username) {
    if (_profile == null) return;

    _profile = _profile!.copyWith(username: username);
    notifyListeners();
  }

  void logout(BuildContext context) {
    _profile = null;
    _isEditingGeneralInfo = false;
    notifyListeners();

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.splash,
      (route) => false,
    );
  }

  void updateAddresses(List<AddressModel> newAddresses) {
    if (_profile == null) return;

    _profile = _profile!.copyWith(addresses: newAddresses);

    _isEditingAddress = false;
    notifyListeners();
  }
}
