import 'package:cqrs/cqrs.dart';

import 'task_models.dart';

// --- Commands ---

class CreateTaskCommand extends Command<String> {
  CreateTaskCommand(this.title);
  final String title;
}

class CreateTaskCommandHandler
    implements CommandHandler<CreateTaskCommand, String> {
  CreateTaskCommandHandler({
    required this._repository,
    required this._publisher,
  });

  final TaskRepository _repository;
  final EventPublisher _publisher;

  @override
  Future<String> execute(CreateTaskCommand command) async {
    final taskId = 'TASK-${DateTime.now().millisecondsSinceEpoch}';
    final task = TaskItem(id: taskId, title: command.title);
    _repository.save(task);
    await _publisher.publishEvent(TaskCreatedEvent(taskId, command.title));
    return taskId;
  }
}

class CompleteTaskCommand extends Command<bool> {
  CompleteTaskCommand(this.taskId);
  final String taskId;
}

class CompleteTaskCommandHandler
    implements CommandHandler<CompleteTaskCommand, bool> {
  CompleteTaskCommandHandler({
    required this._repository,
    required this._publisher,
  });

  final TaskRepository _repository;
  final EventPublisher _publisher;

  @override
  Future<bool> execute(CompleteTaskCommand command) async {
    final existing = _repository.findById(command.taskId);
    if (existing == null) return false;

    _repository.save(existing.copyWith(isCompleted: true));
    await _publisher.publishEvent(TaskCompletedEvent(command.taskId));
    return true;
  }
}

// --- Queries ---

class GetTaskByIdQuery extends Query<TaskItem?> {
  GetTaskByIdQuery(this.taskId);
  final String taskId;
}

class GetTaskByIdQueryHandler
    implements QueryHandler<GetTaskByIdQuery, TaskItem?> {
  GetTaskByIdQueryHandler(this._repository);
  final TaskRepository _repository;

  @override
  Future<TaskItem?> execute(GetTaskByIdQuery query) async {
    return _repository.findById(query.taskId);
  }
}

class ListTasksQuery extends Query<List<TaskItem>> {
  const ListTasksQuery();
}

class ListTasksQueryHandler
    implements QueryHandler<ListTasksQuery, List<TaskItem>> {
  ListTasksQueryHandler(this._repository);
  final TaskRepository _repository;

  @override
  Future<List<TaskItem>> execute(ListTasksQuery query) async {
    return _repository.findAll();
  }
}

// --- Stream Query ---

class WatchTasksQuery extends StreamQuery<List<TaskItem>> {
  const WatchTasksQuery();
}

class WatchTasksQueryHandler
    implements StreamQueryHandler<WatchTasksQuery, List<TaskItem>> {
  WatchTasksQueryHandler(this._repository);
  final TaskRepository _repository;

  @override
  Stream<List<TaskItem>> execute(WatchTasksQuery query) {
    return _repository.watchTasks();
  }
}

// --- Event Handlers ---

class TaskNotificationHandler implements EventHandler<TaskCreatedEvent> {
  final List<String> notifications = [];

  @override
  Future<void> handle(TaskCreatedEvent event) async {
    notifications.add('New Task: "${event.title}" (${event.taskId})');
  }
}

class TaskAuditLogHandler {
  final List<String> auditLogs = [];

  void logCreated(TaskCreatedEvent event) {
    auditLogs.add('[AUDIT] Created task ${event.taskId}');
  }

  void logCompleted(TaskCompletedEvent event) {
    auditLogs.add('[AUDIT] Completed task ${event.taskId}');
  }
}

class TaskCreatedAuditHandler implements EventHandler<TaskCreatedEvent> {
  TaskCreatedAuditHandler(this._auditLogger);
  final TaskAuditLogHandler _auditLogger;

  @override
  Future<void> handle(TaskCreatedEvent event) async {
    _auditLogger.logCreated(event);
  }
}

class TaskCompletedAuditHandler implements EventHandler<TaskCompletedEvent> {
  TaskCompletedAuditHandler(this._auditLogger);
  final TaskAuditLogHandler _auditLogger;

  @override
  Future<void> handle(TaskCompletedEvent event) async {
    _auditLogger.logCompleted(event);
  }
}
