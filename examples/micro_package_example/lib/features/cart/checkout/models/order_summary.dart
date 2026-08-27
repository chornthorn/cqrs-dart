class OrderSummary {
  final String orderId;
  final double totalAmount;
  final String status;
  final DateTime createdAt;

  const OrderSummary({
    required this.orderId,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });
}
