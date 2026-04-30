import 'package:ct484tx_project_trangdc24v7x324/core/pocketbase_client.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/app_notification_model.dart';

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

    return records
        .map((record) => AppNotificationModel.fromJson(record.toJson()))
        .toList();
  }

  Future<void> createManagerNotification({
    required String title,
    required String body,
    required String type,
  }) async {
    await pb
        .collection('notifications')
        .create(
          body: {
            'title': title,
            'body': body,
            'type': type,
            'targetRole': 'customer',
          },
        );
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
            'title': title,
            'body': body,
            'type': type,
            'targetRole': targetRole,
            'targetUser': targetUser,
            'orderId': orderId,
          },
        );
  }
}
