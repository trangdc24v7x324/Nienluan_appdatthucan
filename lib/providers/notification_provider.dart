import 'package:flutter/material.dart';
import 'package:CT466_project_trangdc24v7x324/core/pocketbase_client.dart';
import 'package:CT466_project_trangdc24v7x324/models/app_notification_model.dart';
import 'package:CT466_project_trangdc24v7x324/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  final List<AppNotificationModel> _notifications = [];

  bool _isLoading = false;
  bool _isCreating = false;

  String? _errorMessage;

  List<AppNotificationModel> get notifications {
    return List.unmodifiable(_notifications);
  }

  bool get isLoading => _isLoading;

  bool get isCreating => _isCreating;

  String? get errorMessage => _errorMessage;

  int get unreadCount {
    return _notifications.where((item) => !item.isRead).length;
  }

  bool get hasUnread => unreadCount > 0;

  List<AppNotificationModel> get unreadNotifications {
    return _notifications.where((item) => !item.isRead).toList();
  }

  List<AppNotificationModel> get readNotifications {
    return _notifications.where((item) => item.isRead).toList();
  }

  Future<void> loadCustomerNotifications() async {
    final userId = pb.authStore.model?.id;

    if (userId == null || userId.isEmpty) return;

    _setLoading(true);
    _clearError();

    try {
      final result = await _service.fetchCustomerNotifications(userId: userId);

      _notifications
        ..clear()
        ..addAll(result);
    } catch (e) {
      _setError('Không thể tải thông báo');
      debugPrint('loadCustomerNotifications error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadManagerNotifications() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _service.fetchManagerNotifications();

      _notifications
        ..clear()
        ..addAll(result);
    } catch (e) {
      _setError('Không thể tải thông báo quản lý');
      debugPrint('loadManagerNotifications error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      await _service.markAsRead(notificationId);

      final index = _notifications.indexWhere(
        (item) => item.id == notificationId,
      );

      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('Không thể đánh dấu đã đọc');
      debugPrint('markAsRead error: $e');
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      await _service.markAllAsRead(_notifications);

      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }

      notifyListeners();

      return true;
    } catch (e) {
      _setError('Không thể đánh dấu tất cả đã đọc');
      debugPrint('markAllAsRead error: $e');
      return false;
    }
  }

  Future<bool> createManagerNotification({
    required String title,
    required String body,
    required String type,
  }) async {
    _isCreating = true;
    _clearError();
    notifyListeners();

    try {
      await _service.createManagerNotification(
        title: title,
        body: body,
        type: type,
      );

      return true;
    } catch (e) {
      _setError('Tạo thông báo thất bại');
      debugPrint('createManagerNotification error: $e');
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _service.deleteNotification(notificationId);

      _notifications.removeWhere((item) => item.id == notificationId);

      notifyListeners();

      return true;
    } catch (e) {
      _setError('Xóa thông báo thất bại');
      debugPrint('deleteNotification error: $e');
      return false;
    }
  }

  void clearNotifications() {
    _notifications.clear();
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
