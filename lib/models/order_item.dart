class OrderItem {
  final String id;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final DateTime orderDate;
  final String status;

  OrderItem({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    required this.status,
  });
}
