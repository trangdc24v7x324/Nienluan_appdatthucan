import 'package:CT466_project_trangdc24v7x324/core/pocketbase_client.dart';
import 'package:CT466_project_trangdc24v7x324/models/app_notification_model.dart';

class NotificationService {
  Future<List<AppNotificationModel>> fetchCustomerNotifications({
    required String userId,
  }) async {
    final records = await pb
        .collection('notifications')
        .getFullList(
          sort: '-created',
          filter:
              'targetRole = "customer" || targetRole = "all" || (targetRole = "personal" && targetUser = "$userId")',
        );

    return records.map((record) {
      return AppNotificationModel.fromJson({
        'id': record.id,
        ...record.data,
        'created': record.created,
        'updated': record.updated,
      });
    }).toList();
  }

  Future<List<AppNotificationModel>> fetchManagerNotifications() async {
    final records = await pb
        .collection('notifications')
        .getFullList(
          sort: '-created',
          filter: 'targetRole = "manager" || targetRole = "all"',
        );

    return records.map((record) {
      return AppNotificationModel.fromJson({
        'id': record.id,
        ...record.data,
        'created': record.created,
        'updated': record.updated,
      });
    }).toList();
  }

  Future<void> createManagerNotification({
    required String title,
    required String body,
    required String type,
  }) async {
    await create(title: title, body: body, type: type, targetRole: 'customer');
  }

  Future<void> create({
    required String title,
    required String body,
    required String type,
    required String targetRole,
    String? targetUser,
    String? orderId,
  }) async {
    await pb
        .collection('notifications')
        .create(
          body: {
            'title': title.trim(),
            'body': body.trim(),
            'type': type.trim(),
            'targetRole': targetRole,
            'targetUser': targetUser,
            'orderId': orderId,
            'isRead': false,
          },
        );
  }

  Future<void> markAsRead(String notificationId) async {
    await pb
        .collection('notifications')
        .update(notificationId, body: {'isRead': true});
  }

  Future<void> markAllAsRead(List<AppNotificationModel> notifications) async {
    for (final item in notifications) {
      if (!item.isRead) {
        await markAsRead(item.id);
      }
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    await pb.collection('notifications').delete(notificationId);
  }
}
