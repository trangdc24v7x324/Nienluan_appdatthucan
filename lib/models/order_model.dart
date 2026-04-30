import 'package:ct484tx_project_trangdc24v7x324/models/cart_item_model.dart';

class OrderModel {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime orderDate;
  final String status;

  final String receiverName;
  final String receiverPhone;
  final String address;
  final String paymentMethod;
  final String note;

  OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    required this.status,
    required this.receiverName,
    required this.receiverPhone,
    required this.address,
    required this.paymentMethod,
    required this.note,
  });
}
