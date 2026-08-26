import 'dart:async';

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

/// In-memory repository with real-time stream broadcast
class TaskRepository {
  final Map<String, TaskItem> _tasks = {};
  final StreamController<List<TaskItem>> _streamController =
      StreamController<List<TaskItem>>.broadcast();

  Stream<List<TaskItem>> watchTasks() async* {
    yield _tasks.values.toList(growable: false);
    yield* _streamController.stream;
  }

  void save(TaskItem task) {
    _tasks[task.id] = task;
    _streamController.add(_tasks.values.toList(growable: false));
  }

  TaskItem? findById(String id) => _tasks[id];

  List<TaskItem> findAll() => _tasks.values.toList(growable: false);

  void dispose() {
    _streamController.close();
  }
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
