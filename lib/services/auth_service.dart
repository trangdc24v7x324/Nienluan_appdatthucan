import 'package:ct484tx_project_trangdc24v7x324/core/pocketbase_client.dart';

class AuthService {
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      await pb
          .collection('users')
          .create(
            body: {
              'email': email,
              'password': password,
              'passwordConfirm': password,
              'fullName': fullName,
              'phoneNumber': phoneNumber,
              'role': 'customer',
              'isActive': true,
            },
          );
    } catch (e) {
      print('REGISTER ERROR: $e');
      rethrow;
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      await pb.collection('users').authWithPassword(email, password);
    } catch (e) {
      print('LOGIN ERROR: $e');
      rethrow;
    }
  }

  void logout() {
    pb.authStore.clear();
  }

  bool get isLoggedIn => pb.authStore.isValid;

  String? get currentUserId => pb.authStore.model?.id;

  Map<String, dynamic>? get currentUser {
    final model = pb.authStore.model;
    if (model == null) return null;
    return model.toJson();
  }

  String get currentUserRole {
    final model = pb.authStore.model;
    if (model == null) return 'customer';

    final data = model.toJson();
    return (data['role'] ?? 'customer').toString();
  }

  String get currentUserFullName {
    final model = pb.authStore.model;
    if (model == null) return '';

    final data = model.toJson();
    return (data['fullName'] ?? '').toString();
  }

  String get currentUserEmail {
    final model = pb.authStore.model;
    if (model == null) return '';

    final data = model.toJson();
    return (data['email'] ?? '').toString();
  }

  String get currentUserPhoneNumber {
    final model = pb.authStore.model;
    if (model == null) return '';

    final data = model.toJson();
    return (data['phoneNumber'] ?? '').toString();
  }

  bool get isManager => currentUserRole == 'manager';

  bool get isCustomer => currentUserRole == 'customer';

  bool get isActive {
    final model = pb.authStore.model;
    if (model == null) return false;

    final data = model.toJson();
    return data['isActive'] == true;
  }

  Future<Map<String, dynamic>?> refreshCurrentUser() async {
    try {
      if (!pb.authStore.isValid) return null;

      final userId = pb.authStore.model?.id;
      if (userId == null) return null;

      final record = await pb.collection('users').getOne(userId);
      return record.toJson();
    } catch (e) {
      print('REFRESH USER ERROR: $e');
      return null;
    }
  }
}
