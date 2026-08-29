import 'package:injectable/injectable.dart';

@Injectable()
class DiscountCalculator {
  final double discountRate;

  DiscountCalculator(@factoryParam this.discountRate);

  double applyDiscount(double amount) =>
      amount * (1.0 - (discountRate / 100.0));
}
