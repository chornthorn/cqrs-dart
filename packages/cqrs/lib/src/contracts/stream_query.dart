/// A read request that emits a stream of [TResult] without mutating state.
abstract class StreamQuery<TResult> {
  const StreamQuery();
}

/// Executes a [TStreamQuery] and returns a [Stream] of its results.
abstract interface class StreamQueryHandler<
    TStreamQuery extends StreamQuery<TResult>, TResult> {
  /// Executes the given [query] and returns a reactive [Stream].
  Stream<TResult> execute(TStreamQuery query);
}
