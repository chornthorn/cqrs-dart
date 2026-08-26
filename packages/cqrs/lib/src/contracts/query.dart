/// A read request that returns [TResult] without mutating state.
abstract class Query<TResult> {
  const Query();
}

/// Executes a [TQuery] and returns its result asynchronously.
abstract interface class QueryHandler<TQuery extends Query<TResult>, TResult> {
  /// Executes the given [query].
  Future<TResult> execute(TQuery query);
}
