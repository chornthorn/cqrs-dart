class CartItem {
  final String productId;
  final String title;
  final double unitPrice;
  final int quantity;

  const CartItem({
    required this.productId,
    required this.title,
    required this.unitPrice,
    required this.quantity,
  });

  double get totalPrice => unitPrice * quantity;
}
