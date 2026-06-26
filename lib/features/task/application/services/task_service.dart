import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/infrastructure/logging/logging_module.dart';
import '../../../../core/infrastructure/logging/app_logger.dart';
import '../../../../core/infrastructure/logging/noop_logger.dart';
import '../../domain/entities/task.dart';
import '../../domain/failures.dart';
import '../../domain/repositories/task_repository.dart';
import '../../infrastructure/repositories/task_repository_impl.dart';

/// Application service for [Task] business logic.
///
/// Orchestrates use cases by combining pure validation with repository calls.
/// Every public method returns a [Result] and is side-effect free in spirit
/// (I/O aside).
final class TaskService {
  final ITaskRepository _repository;
  final IAppLogger _logger;

  TaskService(this._repository, {IAppLogger? logger})
      : _logger = logger ?? const NoOpLogger();

  /// Create a new task after validating its title.
  Future<Result<Task>> createTask({
    required String id,
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
  }) async {
    final titleResult = _validateTitle(title);
    if (titleResult.isFailure) {
      _logger.warning('TaskService.createTask validation failed',
          metadata: {'field': 'title', 'value': title});
      return Result<Task>.failure(titleResult.failureOrNull!);
    }
    final task = Task.create(
      id: id,
      title: titleResult.orNull!.trim(),
      description: description?.trim(),
      priority: priority,
      dueDate: dueDate,
    );
    _logger.info('TaskService.createTask', metadata: {'taskId': id, 'title': task.title});
    return _repository.save(task);
  }

  /// Update an existing task. The task must already exist.
  Future<Result<Task>> updateTask(Task updated) async {
    final titleResult = _validateTitle(updated.title);
    if (titleResult.isFailure) {
      _logger.warning('TaskService.updateTask validation failed',
          metadata: {'taskId': updated.id, 'field': 'title'});
      return Result<Task>.failure(titleResult.failureOrNull!);
    }
    _logger.info('TaskService.updateTask', metadata: {'taskId': updated.id});
    return _repository.save(updated);
  }

  /// Complete a task (transition to [TaskStatus.done]).
  Future<Result<Task>> completeTask(String id) async {
    final result = await _repository.getById(id);
    if (result.isFailure) {
      _logger.warning('TaskService.completeTask failed — not found', metadata: {'taskId': id});
      return Result<Task>.failure(result.failureOrNull!);
    }
    final done = result.orNull!.withStatus(TaskStatus.done);
    _logger.info('TaskService.completeTask', metadata: {'taskId': id});
    return _repository.save(done);
  }

  /// Move a task to in-progress.
  Future<Result<Task>> startTask(String id) async {
    final result = await _repository.getById(id);
    if (result.isFailure) {
      _logger.warning('TaskService.startTask failed — not found', metadata: {'taskId': id});
      return Result<Task>.failure(result.failureOrNull!);
    }
    final inProgress = result.orNull!.withStatus(TaskStatus.inProgress);
    _logger.info('TaskService.startTask', metadata: {'taskId': id});
    return _repository.save(inProgress);
  }

  /// Get all tasks.
  Future<Result<List<Task>>> getAllTasks() {
    _logger.debug('TaskService.getAllTasks');
    return _repository.getAll();
  }

  /// Get tasks by status.
  Future<Result<List<Task>>> getTasksByStatus(TaskStatus status) {
    _logger.debug('TaskService.getTasksByStatus', metadata: {'status': status.name});
    return _repository.getByStatus(status);
  }

  /// Delete a task.
  Future<Result<void>> deleteTask(String id) {
    _logger.info('TaskService.deleteTask', metadata: {'taskId': id});
    return _repository.delete(id);
  }

  /// Pure function: validate that a title is non-empty and not too long.
  Result<String> _validateTitle(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      return Result<String>.failure(
        const TaskValidationFailure(field: 'title', message: 'Title must not be empty'),
      );
    }
    if (trimmed.length > 100) {
      return Result<String>.failure(
        const TaskValidationFailure(field: 'title', message: 'Title must be 100 characters or fewer'),
      );
    }
    return Result.success(trimmed);
  }
}

/// Riverpod provider for [TaskService].
final taskServiceProvider = Provider<TaskService>((ref) {
  final repository = ref.read(taskRepositoryProvider);
  final logger = ref.read(appLoggerProvider);
  return TaskService(repository, logger: logger);
});
