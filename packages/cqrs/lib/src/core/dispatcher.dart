import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'cqrs.dart';

/// Routes commands, queries, and events to handlers registered in GetIt.
///
/// This is the only CQRS type UI and application code should depend on.
@singleton
class CqrsDispatcher {
  final GetIt _getIt = GetIt.instance;

  /// Resolves the single [QueryHandler] registered for [query] and executes it.
  Future<TResult> dispatchQuery<TQuery extends Query<TResult>, TResult>(
    TQuery query,
  ) {
    final handler = _getIt<QueryHandler<TQuery, TResult>>();
    return handler.execute(query);
  }

  /// Resolves the single [CommandHandler] registered for [command] and executes it.
  Future<TResult> dispatchCommand<TCommand extends Command<TResult>, TResult>(
    TCommand command,
  ) {
    final handler = _getIt<CommandHandler<TCommand, TResult>>();
    return handler.execute(command);
  }

  /// Publishes [event] to every [EventHandler] registered for that event type.
  ///
  /// Handlers run concurrently. Publishing an event with no listeners is a no-op.
  Future<void> publishEvent<TEvent extends DomainEvent>(TEvent event) async {
    if (!_getIt.isRegistered<EventHandler<TEvent>>()) {
      return;
    }

    final handlers = _getIt.getAll<EventHandler<TEvent>>();
    await Future.wait(handlers.map((handler) => handler.handle(event)));
  }
}
