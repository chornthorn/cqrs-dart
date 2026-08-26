import '../contracts/query.dart';
import '../contracts/stream_query.dart';

/// Contract for dispatching queries.
abstract interface class QueryDispatcher {
  /// Resolves the registered [QueryHandler] for [query] and executes it.
  Future<TResult> dispatchQuery<TQuery extends Query<TResult>, TResult>(
    TQuery query,
  );

  /// Resolves the registered [StreamQueryHandler] for [query] and executes it.
  Stream<TResult>
      dispatchStreamQuery<TStreamQuery extends StreamQuery<TResult>, TResult>(
    TStreamQuery query,
  );
}
