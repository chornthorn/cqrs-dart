import 'package:cqrs/cqrs.dart';

/// Domain Entity
class TaskItem {
  TaskItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final bool isCompleted;

  TaskItem copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// In-memory repository
class TaskRepository {
  final Map<String, TaskItem> _tasks = {};

  void save(TaskItem task) {
    _tasks[task.id] = task;
  }

  TaskItem? findById(String id) => _tasks[id];

  List<TaskItem> findAll() => _tasks.values.toList(growable: false);
}

/// Domain Events
class TaskCreatedEvent extends DomainEvent {
  TaskCreatedEvent(this.taskId, this.title);
  final String taskId;
  final String title;
}

class TaskCompletedEvent extends DomainEvent {
  TaskCompletedEvent(this.taskId);
  final String taskId;
}
