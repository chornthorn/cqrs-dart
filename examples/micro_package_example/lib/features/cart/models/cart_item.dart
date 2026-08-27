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

  CartItem copyWith({
    String? productId,
    String? title,
    double? unitPrice,
    int? quantity,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      title: title ?? this.title,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }
}
