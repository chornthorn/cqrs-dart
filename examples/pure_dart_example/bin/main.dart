import 'package:cqrs/cqrs.dart';
import 'package:pure_dart_example/pure_dart_example.dart';

void main() async {
  print('=== Pure Dart CQRS (No DI, No Codegen) ===\n');

  // 1. Shared state & services
  final taskRepository = TaskRepository();
  final notificationHandler = TaskNotificationHandler();
  final auditLogger = TaskAuditLogHandler();
  final loggingMiddleware = LoggingCommandMiddleware();

  // 2. Dispatcher with internal default registry
  final dispatcher = CqrsDispatcher(
    commandMiddlewares: [loggingMiddleware],
  );

  // 3. Register commands, queries, stream queries, and events via dispatcher.registry
  dispatcher.registry
    ..registerCommand<CreateTaskCommand, String>(
      () => CreateTaskCommandHandler(
        repository: taskRepository,
        publisher: dispatcher,
      ),
    )
    ..registerCommand<CompleteTaskCommand, bool>(
      () => CompleteTaskCommandHandler(
        repository: taskRepository,
        publisher: dispatcher,
      ),
    )
    ..registerQuery<GetTaskByIdQuery, TaskItem?>(
      () => GetTaskByIdQueryHandler(taskRepository),
    )
    ..registerQuery<ListTasksQuery, List<TaskItem>>(
      () => ListTasksQueryHandler(taskRepository),
    )
    ..registerStreamQuery<WatchTasksQuery, List<TaskItem>>(
      () => WatchTasksQueryHandler(taskRepository),
    )
    ..registerEvent<TaskCreatedEvent>(() => notificationHandler)
    ..registerEvent<TaskCreatedEvent>(() => TaskCreatedAuditHandler(auditLogger))
    ..registerEvent<TaskCompletedEvent>(() => TaskCompletedAuditHandler(auditLogger));

  // 4. Subscribe to reactive StreamQuery
  final taskStream = dispatcher.streamQuery(const WatchTasksQuery());
  final streamSubscription = taskStream.listen((tasks) {
    print('  [Reactive Stream Update] Total tasks in list: ${tasks.length}');
  });

  // Small delay for initial stream emission
  await Future<void>.delayed(const Duration(milliseconds: 10));

  // 5. Dispatch Commands
  print('\n-- Step 1: Creating Tasks --');
  final task1Id = await dispatcher.command(
    CreateTaskCommand('Design pure Dart CQRS core'),
  );
  await dispatcher.command(
    CreateTaskCommand('Write pure manual registration example'),
  );

  // Small delay for stream updates
  await Future<void>.delayed(const Duration(milliseconds: 10));

  // 6. Dispatch Queries
  print('\n-- Step 2: Querying Tasks --');
  final task1 = await dispatcher.query(GetTaskByIdQuery(task1Id));
  print('Found task: "${task1?.title}" (Completed: ${task1?.isCompleted})');

  final allTasks = await dispatcher.query(const ListTasksQuery());
  print('All tasks count: ${allTasks.length}');

  // 7. Complete a Task
  print('\n-- Step 3: Completing Task --');
  final completed = await dispatcher.command(CompleteTaskCommand(task1Id));
  print('Task completed successfully: $completed');

  await Future<void>.delayed(const Duration(milliseconds: 10));

  // 8. Inspect Notifications and Audit Logs (Side effects)
  print('\n-- Step 4: Side Effects & Handled Events --');
  print('Notifications:');
  for (final note in notificationHandler.notifications) {
    print('  - $note');
  }

  print('Audit Logs:');
  for (final log in auditLogger.auditLogs) {
    print('  - $log');
  }

  print('\nMiddleware Execution Logs:');
  for (final log in loggingMiddleware.logs) {
    print('  $log');
  }

  // Cleanup
  await streamSubscription.cancel();
  taskRepository.dispose();
  print('\nDone!');
}
