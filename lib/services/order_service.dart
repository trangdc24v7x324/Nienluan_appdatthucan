import 'package:CT466_project_trangdc24v7x324/core/pocketbase_client.dart';
import 'package:CT466_project_trangdc24v7x324/models/cart_item_model.dart';
import 'package:CT466_project_trangdc24v7x324/models/order_item_model.dart';
import 'package:CT466_project_trangdc24v7x324/models/order_model.dart';
import 'package:CT466_project_trangdc24v7x324/services/notification_service.dart';

class OrderService {
  final NotificationService _notificationService = NotificationService();

  Future<void> createOrder({
    required List<CartItemModel> items,
    required double totalAmount,
    required String receiverName,
    required String receiverPhone,
    required String deliveryAddress,
    required String paymentMethod,
    required String note,
  }) async {
    final authUser = pb.authStore.model;

    if (authUser == null) {
      throw Exception('Chưa đăng nhập');
    }

    if (items.isEmpty) {
      throw Exception('Giỏ hàng đang trống');
    }

    final subtotal = items.fold<double>(0, (sum, item) => sum + item.subtotal);

    final orderRecord = await pb
        .collection('orders')
        .create(
          body: {
            'user': authUser.id,
            'receiver_name': receiverName.trim(),
            'receiver_phone': receiverPhone.trim(),
            'delivery_address': deliveryAddress.trim(),
            'payment_method': paymentMethod.trim(),
            'payment_status': _getInitialPaymentStatus(paymentMethod),
            'order_status': 'placed',
            'subtotal': subtotal,
            'delivery_fee': 0,
            'discount_amount': 0,
            'total_amount': totalAmount,
            'note': note.trim(),
            'cancel_reason': '',
          },
        );

    try {
      for (final item in items) {
        if (item.productId.trim().isEmpty) {
          throw Exception('Sản phẩm "${item.title}" bị thiếu productId');
        }

        final body = <String, dynamic>{
          'order': orderRecord.id,
          'product': item.productId,
          'product_name': item.title,
          'product_image': item.image,
          'unit_price': item.price,
          'quantity': item.quantity,
          'subtotal': item.subtotal,
          'note': '',
          'category_title': item.categoryTitle,
          'category_slug': item.categorySlug,
        };

        if (item.categoryId.trim().isNotEmpty) {
          body['category'] = item.categoryId;
        }

        await pb.collection('order_items').create(body: body);
      }
    } catch (e) {
      print('Tạo order thành công nhưng tạo order_items thất bại: $e');

      try {
        await pb.collection('orders').delete(orderRecord.id);
      } catch (deleteError) {
        print('Không thể rollback đơn hàng ${orderRecord.id}: $deleteError');
      }

      throw Exception('Không thể tạo chi tiết đơn hàng: $e');
    }

    try {
      await _notificationService.create(
        title: 'Đặt hàng thành công',
        body: 'Đơn hàng của bạn đã được tạo thành công.',
        type: 'order',
        targetRole: 'personal',
        targetUser: authUser.id,
        orderId: orderRecord.id,
      );

      await _notificationService.create(
        title: 'Có đơn hàng mới',
        body: 'Một khách hàng vừa đặt đơn hàng mới.',
        type: 'order',
        targetRole: 'manager',
        orderId: orderRecord.id,
      );
    } catch (e) {
      print('Tạo đơn thành công nhưng tạo thông báo lỗi: $e');
    }
  }

  Future<List<OrderModel>> fetchMyOrders() async {
    final authUser = pb.authStore.model;

    if (authUser == null) {
      throw Exception('Chưa đăng nhập');
    }

    final orderRecords = await pb
        .collection('orders')
        .getFullList(filter: 'user = "${authUser.id}"', sort: '-created');

    return _mapOrderRecords(orderRecords);
  }

  Future<List<OrderModel>> fetchAllOrders() async {
    final orderRecords = await pb
        .collection('orders')
        .getFullList(sort: '-created');

    return _mapOrderRecords(orderRecords);
  }

  Future<OrderModel> fetchOrderDetail(String orderId) async {
    final orderRecord = await pb.collection('orders').getOne(orderId);

    final items = await _fetchOrderItems(orderId);

    return OrderModel.fromJson({
      'id': orderRecord.id,
      ...orderRecord.data,
      'created': orderRecord.created,
      'updated': orderRecord.updated,
    }, items: items);
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    String cancelReason = '',
  }) async {
    final body = <String, dynamic>{'order_status': status};

    if (status == 'cancelled') {
      body['cancel_reason'] = cancelReason.trim();
    }

    final order = await pb.collection('orders').update(orderId, body: body);

    final userId = (order.data['user'] ?? '').toString();

    print('===== UPDATE ORDER STATUS =====');
    print('Order ID: $orderId');
    print('Status: $status');
    print('Customer ID: $userId');
    print('Order data: ${order.data}');
    print('===============================');

    if (userId.isEmpty) {
      print('Không tạo notification vì userId rỗng');
      return;
    }

    try {
      await _createOrderStatusNotification(
        userId: userId,
        orderId: orderId,
        status: status,
      );

      print('Đã tạo thông báo trạng thái đơn hàng');
    } catch (e) {
      print('Lỗi tạo thông báo trạng thái đơn hàng: $e');
    }
  }

  Future<void> updatePaymentStatus({
    required String orderId,
    required String paymentStatus,
  }) async {
    await pb
        .collection('orders')
        .update(orderId, body: {'payment_status': paymentStatus});
  }

  Future<List<OrderModel>> _mapOrderRecords(List<dynamic> orderRecords) async {
    final List<OrderModel> orders = [];

    for (final orderRecord in orderRecords) {
      final items = await _fetchOrderItems(orderRecord.id);

      orders.add(
        OrderModel.fromJson({
          'id': orderRecord.id,
          ...orderRecord.data,
          'created': orderRecord.created,
          'updated': orderRecord.updated,
        }, items: items),
      );
    }

    return orders;
  }

  Future<List<OrderItemModel>> _fetchOrderItems(String orderId) async {
    final itemRecords = await pb
        .collection('order_items')
        .getFullList(filter: 'order = "$orderId"', sort: 'created');

    return itemRecords.map((record) {
      return OrderItemModel.fromJson({
        'id': record.id,
        ...record.data,
        'created': record.created,
        'updated': record.updated,
      });
    }).toList();
  }

  String _getInitialPaymentStatus(String paymentMethod) {
    final value = paymentMethod.toLowerCase().trim();

    if (value == 'cash' ||
        value == 'tiền mặt' ||
        value == 'tien mat' ||
        value.contains('cash')) {
      return 'unpaid';
    }

    return 'paid';
  }

  Future<void> _createOrderStatusNotification({
    required String userId,
    required String orderId,
    required String status,
  }) async {
    String title = 'Cập nhật đơn hàng';
    String body = 'Trạng thái đơn hàng của bạn đã được cập nhật.';

    if (status == 'confirmed') {
      title = 'Đơn hàng đã được xác nhận';
      body = 'Đơn hàng của bạn đã được cửa hàng xác nhận.';
    } else if (status == 'preparing') {
      title = 'Đơn hàng đang được chuẩn bị';
      body = 'Cửa hàng đang chuẩn bị đơn hàng của bạn.';
    } else if (status == 'delivering') {
      title = 'Đơn hàng đang được giao';
      body = 'Đơn hàng của bạn đang trên đường giao đến bạn.';
    } else if (status == 'completed') {
      title = 'Đơn hàng đã giao thành công';
      body = 'Đơn hàng của bạn đã được giao thành công.';
    } else if (status == 'cancelled') {
      title = 'Đơn hàng đã bị hủy';
      body = 'Đơn hàng của bạn đã bị hủy.';
    }

    await _notificationService.create(
      title: title,
      body: body,
      type: 'order',
      targetRole: 'personal',
      targetUser: userId,
      orderId: orderId,
    );
  }
}
