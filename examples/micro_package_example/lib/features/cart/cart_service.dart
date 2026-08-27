import 'package:injectable/injectable.dart';

import 'models/cart_item.dart';

@Injectable(scope: Scope.lazySingleton)
class CartService {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  void addItem({
    required String productId,
    required String title,
    required double unitPrice,
    required int quantity,
  }) {
    final existingIndex =
        _items.indexWhere((item) => item.productId == productId);
    if (existingIndex >= 0) {
      final existing = _items[existingIndex];
      _items[existingIndex] =
          existing.copyWith(quantity: existing.quantity + quantity);
    } else {
      _items.add(CartItem(
        productId: productId,
        title: title,
        unitPrice: unitPrice,
        quantity: quantity,
      ));
    }
  }

  double get subtotal =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  void clear() => _items.clear();
}
