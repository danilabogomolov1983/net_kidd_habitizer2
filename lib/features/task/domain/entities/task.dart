import 'package:equatable/equatable.dart';
import '../../../../core/domain/base_types.dart';

/// Supported task statuses.
enum TaskStatus { todo, inProgress, done }

/// Supported task priority levels.
enum TaskPriority { low, medium, high }

/// The central [Task] domain entity.
///
/// Represents a single task in the habit tracker. Every task has a unique
/// [id], a required [title], and optional metadata.
///
/// **Functional style**: all fields are `final`; mutations return a new
/// [Task] via [copyWith].
final class Task extends Equatable implements IEntity {
  @override
  final String id;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a [Task] with factory defaults for new items.
  factory Task.create({
    required String id,
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
  }) {
    final now = DateTime.now();
    return Task(
      id: id,
      title: title,
      description: description,
      status: TaskStatus.todo,
      priority: priority,
      dueDate: dueDate,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Functional copy method — returns a new [Task] with some fields replaced.
  Task copyWith({
    String? id,
    String? title,
    String? Function()? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? Function()? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description != null ? description() : this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate != null ? dueDate() : this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Transition the task to a new [status] with an updated timestamp.
  Task withStatus(TaskStatus newStatus) => copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        status,
        priority,
        dueDate,
        createdAt,
        updatedAt,
      ];
}
