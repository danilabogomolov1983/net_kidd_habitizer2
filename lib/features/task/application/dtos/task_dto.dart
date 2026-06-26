import '../../domain/entities/task.dart';

/// Data Transfer Object for [Task].
///
/// Bridges the gap between raw SQLite rows and domain entities.
/// The mapping functions are pure, top-level functions (functional style).
final class TaskDto {
  final String id;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final String? dueDate;
  final String createdAt;
  final String updatedAt;

  const TaskDto({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskDto.fromMap(Map<String, Object?> map) {
    return TaskDto(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      status: map['status'] as String,
      priority: map['priority'] as String,
      dueDate: map['due_date'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'status': status,
        'priority': priority,
        'due_date': dueDate,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

/// Pure function: map [TaskDto] → [Task].
Task taskFromDto(TaskDto dto) => Task(
      id: dto.id,
      title: dto.title,
      description: dto.description,
      status: _parseStatus(dto.status),
      priority: _parsePriority(dto.priority),
      dueDate: dto.dueDate != null ? DateTime.tryParse(dto.dueDate!) : null,
      createdAt: DateTime.parse(dto.createdAt),
      updatedAt: DateTime.parse(dto.updatedAt),
    );

/// Pure function: map [Task] → [TaskDto].
TaskDto taskToDto(Task task) => TaskDto(
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status.name,
      priority: task.priority.name,
      dueDate: task.dueDate?.toIso8601String(),
      createdAt: task.createdAt.toIso8601String(),
      updatedAt: task.updatedAt.toIso8601String(),
    );

TaskStatus _parseStatus(String value) => TaskStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskStatus.todo,
    );

TaskPriority _parsePriority(String value) => TaskPriority.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskPriority.medium,
    );
