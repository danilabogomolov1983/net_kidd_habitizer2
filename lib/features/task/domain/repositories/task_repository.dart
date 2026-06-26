import '../../../../core/domain/result.dart';
import '../entities/task.dart';

/// Abstract contract for [Task] persistence.
///
/// Declared in the domain layer, implemented in the infrastructure layer
/// (dependency inversion). All methods are pure in intent — they return
/// [Result] and never throw.
abstract interface class ITaskRepository {
  /// Retrieve all tasks ordered by [createdAt] descending.
  Future<Result<List<Task>>> getAll();

  /// Retrieve a single task by [id].
  Future<Result<Task>> getById(String id);

  /// Retrieve tasks that match a given [status].
  Future<Result<List<Task>>> getByStatus(TaskStatus status);

  /// Persist a new task or update an existing one (upsert).
  Future<Result<Task>> save(Task task);

  /// Remove a task by [id].
  Future<Result<void>> delete(String id);

  /// Return tasks associated with a specific tag.
  Future<Result<List<Task>>> getByTagId(String tagId);
}
