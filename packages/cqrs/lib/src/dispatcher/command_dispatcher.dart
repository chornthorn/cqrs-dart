import '../contracts/command.dart';

/// Contract for dispatching commands.
abstract interface class CommandDispatcher {
  /// Resolves the registered [CommandHandler] for [command] and executes it.
  Future<TResult> dispatchCommand<TCommand extends Command<TResult>, TResult>(
    TCommand command,
  );
}
