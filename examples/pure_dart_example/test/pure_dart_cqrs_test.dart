import 'package:cqrs/cqrs.dart';
import 'package:pure_dart_example/pure_dart_example.dart';
import 'package:test/test.dart';

void main() {
  group('Pure Dart Manual CQRS Flow', () {
    late TaskRepository repository;
    late InMemoryHandlerRegistry registry;
    late LoggingCommandMiddleware middleware;
    late DefaultCqrsDispatcher dispatcher;
    late TaskNotificationHandler notificationHandler;
    late TaskAuditLogHandler auditLogger;

    setUp(() {
      repository = TaskRepository();
      registry = InMemoryHandlerRegistry();
      middleware = LoggingCommandMiddleware();
      dispatcher = DefaultCqrsDispatcher(
        registry: registry,
        commandMiddlewares: [middleware],
      );

      notificationHandler = TaskNotificationHandler();
      auditLogger = TaskAuditLogHandler();

      // Manual registration
      registry
        ..registerCommand<CreateTaskCommand, String>(
          () => CreateTaskCommandHandler(
            repository: repository,
            publisher: dispatcher,
          ),
        )
        ..registerCommand<CompleteTaskCommand, bool>(
          () => CompleteTaskCommandHandler(
            repository: repository,
            publisher: dispatcher,
          ),
        )
        ..registerQuery<GetTaskByIdQuery, TaskItem?>(
          () => GetTaskByIdQueryHandler(repository),
        )
        ..registerQuery<ListTasksQuery, List<TaskItem>>(
          () => ListTasksQueryHandler(repository),
        )
        ..registerStreamQuery<WatchTasksQuery, List<TaskItem>>(
          () => WatchTasksQueryHandler(repository),
        )
        ..registerEvent<TaskCreatedEvent>(() => notificationHandler)
        ..registerEvent<TaskCreatedEvent>(() => TaskCreatedAuditHandler(auditLogger))
        ..registerEvent<TaskCompletedEvent>(() => TaskCompletedAuditHandler(auditLogger));
    });

    tearDown(() {
      repository.dispose();
    });

    test('executes command, triggers middleware and publishes events', () async {
      final taskId = await dispatcher.dispatchCommand(
        CreateTaskCommand('Write Unit Tests'),
      );

      expect(taskId, startsWith('TASK-'));

      // Verify repository updated
      final task = repository.findById(taskId);
      expect(task, isNotNull);
      expect(task!.title, 'Write Unit Tests');
      expect(task.isCompleted, isFalse);

      // Verify events delivered
      expect(notificationHandler.notifications.length, 1);
      expect(
        notificationHandler.notifications.first,
        contains('New Task: "Write Unit Tests"'),
      );

      expect(auditLogger.auditLogs, contains('[AUDIT] Created task $taskId'));

      // Verify middleware intercepted
      expect(middleware.logs, contains('--> Command CreateTaskCommand started'));
      expect(
        middleware.logs.any((l) => l.contains('<-- Command CreateTaskCommand succeeded')),
        isTrue,
      );
    });

    test('completes task and queries updated status', () async {
      final taskId = await dispatcher.dispatchCommand(
        CreateTaskCommand('Review PR'),
      );

      final completed = await dispatcher.dispatchCommand(
        CompleteTaskCommand(taskId),
      );
      expect(completed, isTrue);

      final queried = await dispatcher.dispatchQuery(GetTaskByIdQuery(taskId));
      expect(queried, isNotNull);
      expect(queried!.isCompleted, isTrue);

      expect(auditLogger.auditLogs, contains('[AUDIT] Completed task $taskId'));
    });

    test('watches real-time task stream via StreamQuery', () async {
      final stream = dispatcher.dispatchStreamQuery(const WatchTasksQuery());
      final emissions = <int>[];

      final sub = stream.listen((tasks) {
        emissions.add(tasks.length);
      });

      await Future<void>.delayed(const Duration(milliseconds: 10));

      await dispatcher.dispatchCommand(CreateTaskCommand('Task 1'));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await dispatcher.dispatchCommand(CreateTaskCommand('Task 2'));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(emissions, equals([0, 1, 2]));

      await sub.cancel();
    });
  });
}
