import 'dart:async';

import 'package:cqrs/cqrs.dart';

// --- Command & Result ---

class ChargeBillingCommand implements Command<String> {
  const ChargeBillingCommand({
    required this.customerId,
    required this.amount,
  });

  final String customerId;
  final double amount;
}

class ChargeBillingCommandHandler
    implements CommandHandler<ChargeBillingCommand, String> {
  ChargeBillingCommandHandler({required this.publisher});

  final EventPublisher publisher;

  @override
  Future<String> execute(ChargeBillingCommand command) async {
    final chargeId = 'CHG-${command.customerId}';
    await publisher.publish(
      BillingChargedEvent(chargeId: chargeId, amount: command.amount),
    );
    return chargeId;
  }
}

// --- Event & Handler ---

class BillingChargedEvent implements Event {
  const BillingChargedEvent({required this.chargeId, required this.amount});

  final String chargeId;
  final double amount;
}

class BillingNotificationHandler implements EventHandler<BillingChargedEvent> {
  final List<String> notifications = [];

  @override
  Future<void> handle(BillingChargedEvent event) async {
    notifications.add('Charge notification sent for ${event.chargeId}');
  }
}
