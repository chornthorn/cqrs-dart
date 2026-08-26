import '../contracts/query.dart';

/// Contract for dispatching read queries.
abstract interface class QueryDispatcher {
  /// Resolves the registered [QueryHandler] for [query] and executes it.
  Future<TResult> query<TQuery extends Query<TResult>, TResult>(
    TQuery query,
  );
}
