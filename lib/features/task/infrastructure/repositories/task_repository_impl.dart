import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/infrastructure/database/database_module.dart';
import '../../../../core/infrastructure/logging/logging_module.dart';
import '../../../../core/infrastructure/logging/app_logger.dart';
import '../../../../core/infrastructure/logging/noop_logger.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/failures.dart';
import '../../application/dtos/task_dto.dart';
import '../data_sources/task_local_data_source.dart';

/// Concrete implementation of [ITaskRepository] backed by SQLite.
///
/// Delegates SQL execution to [TaskLocalDataSource] and maps DTOs ↔ domain
/// entities via pure functions. Every public method catches exceptions and
/// returns a [Result] — never throws.
final class TaskRepositoryImpl implements ITaskRepository {
  final TaskLocalDataSource _dataSource;
  final IAppLogger _logger;

  TaskRepositoryImpl(this._dataSource, {IAppLogger? logger})
      : _logger = logger ?? const NoOpLogger();

  @override
  Future<Result<List<Task>>> getAll() async {
    try {
      final dtos = await _dataSource.getAll();
      final tasks = dtos.map(taskFromDto).toList();
      _logger.debug('TaskRepositoryImpl.getAll', metadata: {'count': tasks.length});
      return Result.success(tasks);
    } catch (e, s) {
      _logger.error('Failed to load tasks', errorObject: e, stackTrace: s);
      return Result.failure(TaskPersistenceFailure('Failed to load tasks: $e', s));
    }
  }

  @override
  Future<Result<Task>> getById(String id) async {
    try {
      final dto = await _dataSource.getById(id);
      if (dto == null) {
        _logger.warning('Task not found', metadata: {'taskId': id});
        return Result.failure(TaskNotFoundFailure(id));
      }
      return Result.success(taskFromDto(dto));
    } catch (e, s) {
      _logger.error('Failed to load task', metadata: {'taskId': id}, errorObject: e, stackTrace: s);
      return Result.failure(TaskPersistenceFailure('Failed to load task#$id: $e', s));
    }
  }

  @override
  Future<Result<List<Task>>> getByStatus(TaskStatus status) async {
    try {
      final dtos = await _dataSource.getByStatus(status.name);
      final tasks = dtos.map(taskFromDto).toList();
      return Result.success(tasks);
    } catch (e, s) {
      return Result.failure(TaskPersistenceFailure('Failed to load tasks by status: $e', s));
    }
  }

  @override
  Future<Result<Task>> save(Task task) async {
    try {
      final isNew = (await _dataSource.getById(task.id)) == null;
      final dto = taskToDto(task);
      final savedDto = isNew ? await _dataSource.insert(dto) : await _dataSource.update(dto);
      if (savedDto == null) {
        return Result.failure(TaskNotFoundFailure(task.id));
      }
      _logger.info('Task saved', metadata: {'taskId': task.id, 'isNew': isNew});
      return Result.success(taskFromDto(savedDto));
    } catch (e, s) {
      _logger.error('Failed to save task', metadata: {'taskId': task.id}, errorObject: e, stackTrace: s);
      return Result.failure(TaskPersistenceFailure('Failed to save task: $e', s));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _dataSource.delete(id);
      _logger.info('Task deleted', metadata: {'taskId': id});
      return Result.success(null);
    } catch (e, s) {
      _logger.error('Failed to delete task', metadata: {'taskId': id}, errorObject: e, stackTrace: s);
      return Result.failure(TaskPersistenceFailure('Failed to delete task#$id: $e', s));
    }
  }

  @override
  Future<Result<List<Task>>> getByTagId(String tagId) async {
    try {
      final dtos = await _dataSource.getByTagId(tagId);
      final tasks = dtos.map(taskFromDto).toList();
      return Result.success(tasks);
    } catch (e, s) {
      return Result.failure(TaskPersistenceFailure('Failed to load tasks for tag: $e', s));
    }
  }
}

/// Riverpod provider for [ITaskRepository].
///
/// Wires the data source → repository dependency.
final taskRepositoryProvider = Provider<ITaskRepository>((ref) {
  final dbHelper = ref.read(databaseHelperProvider);
  final logger = ref.read(appLoggerProvider);
  final dataSource = TaskLocalDataSource(dbHelper, logger: logger);
  return TaskRepositoryImpl(dataSource, logger: logger);
});

/// Provider that exposes the local data source directly (for tag linking).
final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>((ref) {
  final dbHelper = ref.read(databaseHelperProvider);
  final logger = ref.read(appLoggerProvider);
  return TaskLocalDataSource(dbHelper, logger: logger);
});
