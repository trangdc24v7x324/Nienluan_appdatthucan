import 'package:flutter/material.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/cart_item_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/order_history_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/user_profile_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/routes/app_routes.dart';
import 'package:ct484tx_project_trangdc24v7x324/services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  UserProfileModel? _profile;
  bool _isLoading = false;
  bool _isEditing = false;

  UserProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isEditing => _isEditing;

  Future<void> loadProfile() async {
    if (_profile != null) return;

    _isLoading = true;
    notifyListeners();

    _profile = await _profileService.fetchProfile();

    _isLoading = false;
    notifyListeners();
  }

  void toggleEditMode() {
    _isEditing = !_isEditing;
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
    notifyListeners();
  }

  void updateUsername(String username) {
    if (_profile == null) return;

    _profile = _profile!.copyWith(username: username);
    notifyListeners();
  }

  void addOrder(
    List<CartItem> cartItems,
    double totalAmount, {
    required String paymentMethod,
    String? note,
  }) {
    if (_profile == null) return;

    final now = DateTime.now();

    final newOrder = OrderHistoryModel(
      id: now.millisecondsSinceEpoch.toString(),
      orderCode: '#${now.millisecondsSinceEpoch}',
      orderDate: now,
      totalAmount: totalAmount,
      status: 'Đã giao',
      itemCount: cartItems.fold<int>(0, (sum, item) => sum + item.quantity),
      paymentMethod: paymentMethod,
      note: note,
    );

    final updatedOrders = [newOrder, ..._profile!.orders];

    _profile = _profile!.copyWith(orders: updatedOrders);
    notifyListeners();
  }

  void saveProfile() {
    _isEditing = false;
    notifyListeners();
  }

  void logout(BuildContext context) {
    _profile = null;
    _isEditing = false;
    notifyListeners();

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.splash,
      (route) => false,
    );
  }
}
