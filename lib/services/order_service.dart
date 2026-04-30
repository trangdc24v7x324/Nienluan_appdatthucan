import 'package:ct484tx_project_trangdc24v7x324/core/pocketbase_client.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/cart_item_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/models/order_model.dart';
import 'package:ct484tx_project_trangdc24v7x324/services/notification_service.dart';

class OrderService {
  final NotificationService _notificationService = NotificationService();

  Future<void> createOrder({
    required List<CartItem> items,
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

    final orderRecord = await pb
        .collection('orders')
        .create(
          body: {
            'user': authUser.id,
            'receiver_name': receiverName,
            'receiver_phone': receiverPhone,
            'delivery_address': deliveryAddress,
            'payment_method': paymentMethod,
            'payment_status': paymentMethod == 'Tiền mặt' ? 'unpaid' : 'paid',
            'order_status': 'placed',
            'note': note,
            'cancel_reason': '',
            'subtotal': totalAmount,
            'delivery_fee': 0,
            'discount_amount': 0,
            'total_amount': totalAmount,
          },
        );

    for (final item in items) {
      await pb
          .collection('order_items')
          .create(
            body: {
              'order': orderRecord.id,
              'product': item.productId,
              'product_name': item.title,
              'product_image': item.image,
              'unit_price': item.price,
              'quantity': item.quantity,
              'subtotal': item.price * item.quantity,

              // category snapshot
              'category': item.categoryId,
              'category_title': item.categoryTitle,
              'category_slug': item.categorySlug,
            },
          );
    }

    await _notificationService.create(
      title: 'Đặt hàng thành công',
      body: 'Đơn hàng của bạn đã được tạo thành công.',
      type: 'order_success',
      targetRole: 'personal',
      targetUser: authUser.id,
      orderId: orderRecord.id,
    );
  }

  Future<List<OrderModel>> fetchMyOrders() async {
    final authUser = pb.authStore.model;

    if (authUser == null) {
      throw Exception('Chưa đăng nhập');
    }

    final orderRecords = await pb
        .collection('orders')
        .getFullList(filter: 'user = "${authUser.id}"', sort: '-created');

    final List<OrderModel> orders = [];

    for (final order in orderRecords) {
      final data = order.data;

      final itemRecords = await pb
          .collection('order_items')
          .getFullList(filter: 'order = "${order.id}"', sort: 'created');

      final items =
          itemRecords.map((itemRecord) {
            final item = itemRecord.data;

            return CartItem(
              productId: (item['product'] ?? '').toString(),
              title: (item['product_name'] ?? '').toString(),
              image: (item['product_image'] ?? '').toString(),
              price: ((item['unit_price'] ?? 0) as num).toDouble(),
              quantity: ((item['quantity'] ?? 1) as num).toInt(),

              categoryId: (item['category'] ?? '').toString(),
              categoryTitle: (item['category_title'] ?? 'Khác').toString(),
              categorySlug: (item['category_slug'] ?? 'khac').toString(),
            );
          }).toList();

      orders.add(
        OrderModel(
          id: order.id,
          items: items,
          totalAmount: ((data['total_amount'] ?? 0) as num).toDouble(),
          orderDate: DateTime.tryParse(order.created) ?? DateTime.now(),
          status: (data['order_status'] ?? 'placed').toString(),
          receiverName: (data['receiver_name'] ?? '').toString(),
          receiverPhone: (data['receiver_phone'] ?? '').toString(),
          address: (data['delivery_address'] ?? '').toString(),
          paymentMethod: (data['payment_method'] ?? '').toString(),
          note: (data['note'] ?? '').toString(),
        ),
      );
    }

    return orders;
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final order = await pb
        .collection('orders')
        .update(orderId, body: {'order_status': status});

    final userId = (order.data['user'] ?? '').toString();

    if (userId.isEmpty) return;

    if (status == 'confirmed') {
      await _notificationService.create(
        title: 'Đơn hàng đã được xác nhận',
        body: 'Đơn hàng của bạn đã được cửa hàng xác nhận.',
        type: 'order_confirmed',
        targetRole: 'personal',
        targetUser: userId,
        orderId: orderId,
      );
    } else if (status == 'preparing') {
      await _notificationService.create(
        title: 'Đơn hàng đang được chuẩn bị',
        body: 'Cửa hàng đang chuẩn bị đơn hàng của bạn.',
        type: 'order_preparing',
        targetRole: 'personal',
        targetUser: userId,
        orderId: orderId,
      );
    } else if (status == 'delivering') {
      await _notificationService.create(
        title: 'Đơn hàng đang được giao',
        body: 'Đơn hàng của bạn đang trên đường giao đến bạn.',
        type: 'order_delivering',
        targetRole: 'personal',
        targetUser: userId,
        orderId: orderId,
      );
    } else if (status == 'completed') {
      await _notificationService.create(
        title: 'Đơn hàng đã giao thành công',
        body: 'Đơn hàng của bạn đã được giao thành công.',
        type: 'order_completed',
        targetRole: 'personal',
        targetUser: userId,
        orderId: orderId,
      );
    } else if (status == 'cancelled') {
      await _notificationService.create(
        title: 'Đơn hàng đã bị hủy',
        body: 'Đơn hàng của bạn đã bị hủy.',
        type: 'order_cancelled',
        targetRole: 'personal',
        targetUser: userId,
        orderId: orderId,
      );
    }
  }

  Future<List<OrderModel>> fetchAllOrders() async {
    final orderRecords = await pb
        .collection('orders')
        .getFullList(sort: '-created');

    final List<OrderModel> orders = [];

    for (final order in orderRecords) {
      final data = order.data;

      final itemRecords = await pb
          .collection('order_items')
          .getFullList(filter: 'order = "${order.id}"', sort: 'created');

      final items =
          itemRecords.map((itemRecord) {
            final item = itemRecord.data;

            return CartItem(
              productId: (item['product'] ?? '').toString(),
              title: (item['product_name'] ?? '').toString(),
              image: (item['product_image'] ?? '').toString(),
              price: ((item['unit_price'] ?? 0) as num).toDouble(),
              quantity: ((item['quantity'] ?? 1) as num).toInt(),

              categoryId: (item['category'] ?? '').toString(),
              categoryTitle: (item['category_title'] ?? 'Khác').toString(),
              categorySlug: (item['category_slug'] ?? 'khac').toString(),
            );
          }).toList();

      orders.add(
        OrderModel(
          id: order.id,
          items: items,
          totalAmount: ((data['total_amount'] ?? 0) as num).toDouble(),
          orderDate: DateTime.tryParse(order.created) ?? DateTime.now(),
          status: (data['order_status'] ?? 'placed').toString(),
          receiverName: (data['receiver_name'] ?? '').toString(),
          receiverPhone: (data['receiver_phone'] ?? '').toString(),
          address: (data['delivery_address'] ?? '').toString(),
          paymentMethod: (data['payment_method'] ?? '').toString(),
          note: (data['note'] ?? '').toString(),
        ),
      );
    }

    return orders;
  }
}
