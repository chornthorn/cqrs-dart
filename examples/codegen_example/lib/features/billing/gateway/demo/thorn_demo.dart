// --- Event & Handler ---

import 'package:cqrs_codegen/cqrs_codegen.dart';

class FooBarEvent implements Event {
  const FooBarEvent({required this.name, required this.total});

  final String name;
  final double total;
}

class FooBarEventHandler implements EventHandler<FooBarEvent> {
  final List<String> notifications = [];

  @override
  Future<void> handle(FooBarEvent event) async {
    notifications.add('FooBar sent for ${event.name}');
  }
}
