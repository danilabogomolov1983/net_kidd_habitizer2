import '../../../../core/infrastructure/database/database_helper.dart';
import '../../../../core/infrastructure/logging/app_logger.dart';
import '../../../../core/infrastructure/logging/noop_logger.dart';
import '../../application/dtos/task_dto.dart';

/// SQLite-backed data source for [Task] entities.
///
/// All SQL lives here. This class is the **only** place that touches the
/// `tasks` and `task_tags` tables. The repository implementation delegates
/// to this data source and maps [TaskDto] ↔ [Task] via pure functions.
final class TaskLocalDataSource {
  final DatabaseHelper _dbHelper;
  final IAppLogger _logger;

  TaskLocalDataSource(this._dbHelper, {IAppLogger? logger})
      : _logger = logger ?? const NoOpLogger();

  /// Return all task rows ordered by creation date descending.
  Future<List<TaskDto>> getAll() async {
    _logger.debug('TaskLocalDataSource.getAll');
    final rows = await _dbHelper.rawQuery(
      'SELECT * FROM tasks ORDER BY created_at DESC',
    );
    return rows.map(TaskDto.fromMap).toList();
  }

  /// Return a single task row by [id] or `null`.
  Future<TaskDto?> getById(String id) async {
    final rows = await _dbHelper.rawQuery(
      'SELECT * FROM tasks WHERE id = ?',
      [id],
    );
    if (rows.isEmpty) return null;
    return TaskDto.fromMap(rows.first);
  }

  /// Return tasks matching [status].
  Future<List<TaskDto>> getByStatus(String status) async {
    final rows = await _dbHelper.rawQuery(
      'SELECT * FROM tasks WHERE status = ? ORDER BY created_at DESC',
      [status],
    );
    return rows.map(TaskDto.fromMap).toList();
  }

  /// Insert a new task row.
  Future<TaskDto> insert(TaskDto dto) async {
    _logger.info('TaskLocalDataSource.insert', metadata: {'taskId': dto.id});
    await _dbHelper.rawInsert(
      '''INSERT INTO tasks (id, title, description, status, priority, due_date, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
      [
        dto.id,
        dto.title,
        dto.description,
        dto.status,
        dto.priority,
        dto.dueDate,
        dto.createdAt,
        dto.updatedAt,
      ],
    );
    return dto;
  }

  /// Update an existing task row. Returns the updated row or `null`.
  Future<TaskDto?> update(TaskDto dto) async {
    final count = await _dbHelper.rawUpdate(
      '''UPDATE tasks SET title = ?, description = ?, status = ?, priority = ?,
         due_date = ?, updated_at = ? WHERE id = ?''',
      [
        dto.title,
        dto.description,
        dto.status,
        dto.priority,
        dto.dueDate,
        dto.updatedAt,
        dto.id,
      ],
    );
    if (count == 0) return null;
    return dto;
  }

  /// Delete a task row by [id]. Returns the number of deleted rows.
  Future<int> delete(String id) async {
    _logger.info('TaskLocalDataSource.delete', metadata: {'taskId': id});
    return _dbHelper.rawDelete('DELETE FROM tasks WHERE id = ?', [id]);
  }

  /// Return tasks associated with a given [tagId] via the junction table.
  Future<List<TaskDto>> getByTagId(String tagId) async {
    final rows = await _dbHelper.rawQuery(
      '''SELECT t.* FROM tasks t
         INNER JOIN task_tags tt ON t.id = tt.task_id
         WHERE tt.tag_id = ?
         ORDER BY t.created_at DESC''',
      [tagId],
    );
    return rows.map(TaskDto.fromMap).toList();
  }

  /// Link a task to a tag (many-to-many).
  Future<void> linkTag(String taskId, String tagId) async {
    _logger.info('TaskLocalDataSource.linkTag', metadata: {'taskId': taskId, 'tagId': tagId});
    await _dbHelper.rawInsert(
      'INSERT OR IGNORE INTO task_tags (task_id, tag_id) VALUES (?, ?)',
      [taskId, tagId],
    );
  }

  /// Unlink a task from a tag.
  Future<void> unlinkTag(String taskId, String tagId) async {
    _logger.info('TaskLocalDataSource.unlinkTag', metadata: {'taskId': taskId, 'tagId': tagId});
    await _dbHelper.rawDelete(
      'DELETE FROM task_tags WHERE task_id = ? AND tag_id = ?',
      [taskId, tagId],
    );
  }

  /// Get tag ids linked to a task.
  Future<List<String>> getTagIdsForTask(String taskId) async {
    final rows = await _dbHelper.rawQuery(
      'SELECT tag_id FROM task_tags WHERE task_id = ?',
      [taskId],
    );
    return rows.map((r) => r['tag_id'] as String).toList();
  }
}
