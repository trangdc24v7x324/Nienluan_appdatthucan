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

  Future<void> createCustomerNotification({
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
    String safeType = type.trim();

    if (safeType == 'order' ||
        safeType == 'new_order' ||
        safeType == 'order_success' ||
        safeType == 'order_confirmed' ||
        safeType == 'order_preparing' ||
        safeType == 'order_delivering' ||
        safeType == 'order_completed' ||
        safeType == 'order_cancelled') {
      safeType = 'order_success';
    }

    // Nếu PocketBase chưa có "general" thì quy về promotion.
    if (safeType == 'general') {
      safeType = 'promotion';
    }

    final data = <String, dynamic>{
      'title': title.trim(),
      'body': body.trim(),
      'type': safeType,
      'targetRole': targetRole.trim(),
      'isRead': false,
    };

    if (targetUser != null && targetUser.trim().isNotEmpty) {
      data['targetUser'] = targetUser.trim();
    }

    if (orderId != null && orderId.trim().isNotEmpty) {
      data['orderId'] = orderId.trim();
    }

    print('DATA NOTIFICATION GỬI LÊN: $data');

    await pb.collection('notifications').create(body: data);
  }
  Future<void> createOrderCreatedNotificationForCustomer({
    required String customerId,
    required String orderId,
  }) async {
    await create(
      title: 'Đặt hàng thành công',
      body: 'Đơn hàng của bạn đã được tạo thành công và đang chờ xác nhận.',
      type: 'order',
      targetRole: 'personal',
      targetUser: customerId,
      orderId: orderId,
    );
  }

  Future<void> createOrderStatusNotificationForCustomer({
    required String customerId,
    required String orderId,
    required String statusText,
  }) async {
    await create(
      title: 'Cập nhật đơn hàng',
      body: 'Đơn hàng của bạn $statusText.',
      type: 'order',
      targetRole: 'personal',
      targetUser: customerId,
      orderId: orderId,
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
