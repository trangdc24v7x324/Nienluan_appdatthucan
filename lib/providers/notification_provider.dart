import 'package:flutter/material.dart';
import 'package:ct484tx_project_trangdc24v7x324/core/pocketbase_client.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/app_notification_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  final List<AppNotificationModel> _notifications = [];
  bool _isLoading = false;

  List<AppNotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  int get unreadCount {
    return _notifications.where((item) => !item.isRead).length;
  }

  Future<void> loadCustomerNotifications() async {
    final userId = pb.authStore.model?.id;

    if (userId == null || userId.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _service.fetchCustomerNotifications(userId: userId);

      _notifications
        ..clear()
        ..addAll(result);
    } catch (e) {
      debugPrint('loadCustomerNotifications error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createManagerNotification({
    required String title,
    required String body,
    required String type,
  }) async {
    await _service.createManagerNotification(
      title: title,
      body: body,
      type: type,
    );
  }
}
