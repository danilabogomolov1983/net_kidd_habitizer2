import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/infrastructure/logging/logging_module.dart';
import '../../../../core/infrastructure/logging/app_logger.dart';
import '../../../../core/infrastructure/logging/noop_logger.dart';
import '../../../task/infrastructure/data_sources/task_local_data_source.dart';
import '../../../tag/infrastructure/data_sources/tag_local_data_source.dart';
import '../../../task/infrastructure/repositories/task_repository_impl.dart';
import '../../../tag/infrastructure/repositories/tag_repository_impl.dart';
import '../../../task/domain/failures.dart';
import '../../../tag/domain/failures.dart';

/// Application service that manages the many-to-many relationship between
/// [Task] and [Tag] entities.
///
/// This is NOT a separate feature — it orchestrates two existing feature
/// data sources. Placed in its own slice for clarity.
final class TaskTagService {
  final TaskLocalDataSource _taskDs;
  final TagLocalDataSource _tagDs;
  final IAppLogger _logger;

  TaskTagService(this._taskDs, this._tagDs, {IAppLogger? logger})
      : _logger = logger ?? const NoOpLogger();

  /// Assign a tag to a task.
  Future<Result<void>> assignTag(String taskId, String tagId) async {
    try {
      final task = await _taskDs.getById(taskId);
      if (task == null) {
        _logger.warning('TaskTagService.assignTag task not found', metadata: {'taskId': taskId});
        return Result.failure(TaskNotFoundFailure(taskId));
      }
      final tag = await _tagDs.getById(tagId);
      if (tag == null) {
        _logger.warning('TaskTagService.assignTag tag not found', metadata: {'tagId': tagId});
        return Result.failure(TagNotFoundFailure(tagId));
      }
      await _taskDs.linkTag(taskId, tagId);
      _logger.info('TaskTagService.assignTag', metadata: {'taskId': taskId, 'tagId': tagId});
      return Result.success(null);
    } catch (e, s) {
      _logger.error('Failed to assign tag', metadata: {'taskId': taskId, 'tagId': tagId}, errorObject: e, stackTrace: s);
      return Result.failure(TaskPersistenceFailure('Failed to assign tag: $e', s));
    }
  }

  /// Remove a tag from a task.
  Future<Result<void>> removeTag(String taskId, String tagId) async {
    try {
      await _taskDs.unlinkTag(taskId, tagId);
      _logger.info('TaskTagService.removeTag', metadata: {'taskId': taskId, 'tagId': tagId});
      return Result.success(null);
    } catch (e, s) {
      _logger.error('Failed to remove tag', metadata: {'taskId': taskId, 'tagId': tagId}, errorObject: e, stackTrace: s);
      return Result.failure(TaskPersistenceFailure('Failed to remove tag: $e', s));
    }
  }

  /// Get all tag IDs linked to a task.
  Future<Result<List<String>>> getTagIdsForTask(String taskId) async {
    try {
      final ids = await _taskDs.getTagIdsForTask(taskId);
      _logger.debug('TaskTagService.getTagIdsForTask', metadata: {'taskId': taskId, 'count': ids.length});
      return Result.success(ids);
    } catch (e, s) {
      _logger.error('Failed to get tag ids', metadata: {'taskId': taskId}, errorObject: e, stackTrace: s);
      return Result.failure(TaskPersistenceFailure('Failed to get tag ids: $e', s));
    }
  }
}

/// Riverpod provider for [TaskTagService].
final taskTagServiceProvider = Provider<TaskTagService>((ref) {
  final taskDs = ref.read(taskLocalDataSourceProvider);
  final tagDs = ref.read(tagLocalDataSourceProvider);
  final logger = ref.read(appLoggerProvider);
  return TaskTagService(taskDs, tagDs, logger: logger);
});
