/// A write request that performs a state mutation and returns [TResult].
abstract class Command<TResult> {}

/// Executes a [TCommand] and returns its result asynchronously.
abstract interface class CommandHandler<TCommand extends Command<TResult>, TResult> {
  /// Executes the given [command].
  Future<TResult> execute(TCommand command);
}
