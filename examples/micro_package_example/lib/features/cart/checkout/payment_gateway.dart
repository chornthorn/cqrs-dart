import 'package:injectable/injectable.dart';

@Injectable()
class PaymentGateway {
  Future<bool> processPayment(double amount) async {
    // Simulated payment processing
    return amount > 0;
  }
}
