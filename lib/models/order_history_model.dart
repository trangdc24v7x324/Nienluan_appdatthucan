class OrderHistoryModel {
  final String id;
  final String orderCode;
  final DateTime orderDate;
  final double totalAmount;
  final String status;
  final int itemCount;
  final String paymentMethod;
  final String? note;

  OrderHistoryModel({
    required this.id,
    required this.orderCode,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.itemCount,
    required this.paymentMethod,
    this.note,
  });
}
