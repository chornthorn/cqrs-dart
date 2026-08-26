import 'package:cqrs/cqrs.dart';

/// Intercepts commands to log execution details and execution time.
class LoggingCommandMiddleware implements CommandMiddleware {
  final List<String> logs = [];

  @override
  Future<TResult> handle<TCommand extends Command<TResult>, TResult>(
    TCommand command,
    NextHandler<TResult> next,
  ) async {
    final stopwatch = Stopwatch()..start();
    logs.add('--> Command ${command.runtimeType} started');
    try {
      final result = await next();
      stopwatch.stop();
      logs.add('<-- Command ${command.runtimeType} succeeded in ${stopwatch.elapsedMilliseconds}ms');
      return result;
    } catch (e) {
      stopwatch.stop();
      logs.add('<-- Command ${command.runtimeType} failed: $e');
      rethrow;
    }
  }
}
