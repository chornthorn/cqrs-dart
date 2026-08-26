/// A write request that modifies system state and returns [TResult].
abstract class Command<TResult> {
  const Command();
}

/// Executes a [TCommand] and returns its result asynchronously.
abstract interface class CommandHandler<TCommand extends Command<TResult>,
    TResult> {
  /// Executes the given [command].
  Future<TResult> execute(TCommand command);
}
