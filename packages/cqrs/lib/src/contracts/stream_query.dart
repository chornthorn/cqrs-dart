/// A reactive read request that emits a stream of [TResult].
abstract class StreamQuery<TResult> {}

/// Executes a [TStreamQuery] and returns a reactive [Stream] of results.
abstract interface class StreamQueryHandler<
    TStreamQuery extends StreamQuery<TResult>, TResult> {
  /// Executes the given stream [query].
  Stream<TResult> execute(TStreamQuery query);
}
