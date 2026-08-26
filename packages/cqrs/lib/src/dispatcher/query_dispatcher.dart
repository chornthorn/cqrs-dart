import '../contracts/query.dart';
import '../contracts/stream_query.dart';

/// Contract for dispatching queries.
abstract interface class QueryDispatcher {
  /// Resolves the registered [QueryHandler] for [query] and executes it.
  Future<TResult> query<TQuery extends Query<TResult>, TResult>(
    TQuery query,
  );

  /// Resolves the registered [StreamQueryHandler] for [query] and executes it.
  Stream<TResult>
      streamQuery<TStreamQuery extends StreamQuery<TResult>, TResult>(
    TStreamQuery query,
  );
}
