import 'package:injectable/injectable.dart';

import '../cart_service.dart';
import 'models/order_summary.dart';
import 'payment_gateway.dart';

@Injectable(scope: Scope.lazySingleton)
class CheckoutService {
  final CartService _cartService;
  final PaymentGateway _paymentGateway;

  CheckoutService(this._cartService, this._paymentGateway);

  Future<OrderSummary?> completeCheckout() async {
    final subtotal = _cartService.subtotal;
    if (subtotal <= 0) return null;

    final success = await _paymentGateway.processPayment(subtotal);
    if (!success) return null;

    final summary = OrderSummary(
      orderId: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      totalAmount: subtotal,
      status: 'PAID',
      createdAt: DateTime.now(),
    );

    _cartService.clear();
    return summary;
  }
}
