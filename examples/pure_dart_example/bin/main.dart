import 'package:cqrs/cqrs.dart';
import 'package:pure_dart_example/pure_dart_example.dart';

void main() async {
  print('=== Pure Dart CQRS (No DI, No Codegen) ===\n');

  // 1. Shared state & services
  final taskRepository = TaskRepository();
  final notificationHandler = TaskNotificationHandler();
  final auditLogger = TaskAuditLogHandler();
  final loggingMiddleware = LoggingCommandMiddleware();

  // 2. Pure Dart registry
  final registry = HandlerRegistry();

  // 3. Pure Dart dispatcher
  final dispatcher = CqrsDispatcher(
    registry: registry,
    commandMiddlewares: [loggingMiddleware],
  );

  // 4. Manually register commands, queries, stream queries, and events
  registry
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

  // 5. Subscribe to reactive StreamQuery
  final taskStream = dispatcher.dispatchStreamQuery(const WatchTasksQuery());
  final streamSubscription = taskStream.listen((tasks) {
    print('  [Reactive Stream Update] Total tasks in list: ${tasks.length}');
  });

  // Small delay for initial stream emission
  await Future<void>.delayed(const Duration(milliseconds: 10));

  // 6. Dispatch Commands
  print('\n-- Step 1: Creating Tasks --');
  final task1Id = await dispatcher.dispatchCommand(
    CreateTaskCommand('Design pure Dart CQRS core'),
  );
  await dispatcher.dispatchCommand(
    CreateTaskCommand('Write pure manual registration example'),
  );

  // Small delay for stream updates
  await Future<void>.delayed(const Duration(milliseconds: 10));

  // 7. Dispatch Queries
  print('\n-- Step 2: Querying Tasks --');
  final task1 = await dispatcher.dispatchQuery(GetTaskByIdQuery(task1Id));
  print('Found task: "${task1?.title}" (Completed: ${task1?.isCompleted})');

  final allTasks = await dispatcher.dispatchQuery(const ListTasksQuery());
  print('All tasks count: ${allTasks.length}');

  // 8. Complete a Task
  print('\n-- Step 3: Completing Task --');
  final completed = await dispatcher.dispatchCommand(CompleteTaskCommand(task1Id));
  print('Task completed successfully: $completed');

  await Future<void>.delayed(const Duration(milliseconds: 10));

  // 9. Inspect Notifications and Audit Logs (Side effects)
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
