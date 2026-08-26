import 'dart:async';

import 'package:cqrs/cqrs.dart';

// --- Command & Result ---

class AuthorizePaymentCommand implements Command<String> {
  const AuthorizePaymentCommand({
    required this.transactionId,
    required this.amount,
  });

  final String transactionId;
  final double amount;
}

class AuthorizePaymentCommandHandler
    implements CommandHandler<AuthorizePaymentCommand, String> {
  const AuthorizePaymentCommandHandler();

  @override
  Future<String> execute(AuthorizePaymentCommand command) async {
    return 'AUTH-${command.transactionId}-${command.amount.toInt()}';
  }
}

// --- Query & Result ---

class GetGatewayStatusQuery implements Query<bool> {
  const GetGatewayStatusQuery({required this.gatewayId});

  final String gatewayId;
}

class GetGatewayStatusQueryHandler
    implements QueryHandler<GetGatewayStatusQuery, bool> {
  const GetGatewayStatusQueryHandler();

  @override
  Future<bool> execute(GetGatewayStatusQuery query) async {
    return query.gatewayId.isNotEmpty;
  }
}
