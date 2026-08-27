import 'package:injectable/injectable.dart';
import 'models/cart_item.dart';

@lazySingleton
class CartService {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  void addItem({
    required String productId,
    required String title,
    required double unitPrice,
    int quantity = 1,
  }) {
    _items.add(CartItem(
      productId: productId,
      title: title,
      unitPrice: unitPrice,
      quantity: quantity,
    ));
  }

  double get subtotal => _items.fold(0.0, (sum, i) => sum + i.totalPrice);

  void clear() => _items.clear();
}
