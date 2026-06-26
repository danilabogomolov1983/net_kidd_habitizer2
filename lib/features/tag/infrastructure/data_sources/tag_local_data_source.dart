import '../../../../core/infrastructure/database/database_helper.dart';
import '../../../../core/infrastructure/logging/app_logger.dart';
import '../../../../core/infrastructure/logging/noop_logger.dart';
import '../../application/dtos/tag_dto.dart';

final class TagLocalDataSource {
  final DatabaseHelper _dbHelper;
  final IAppLogger _logger;

  TagLocalDataSource(this._dbHelper, {IAppLogger? logger})
      : _logger = logger ?? const NoOpLogger();

  Future<List<TagDto>> getAll() async {
    _logger.debug('TagLocalDataSource.getAll');
    final rows = await _dbHelper.rawQuery(
      'SELECT * FROM tags ORDER BY name ASC',
    );
    return rows.map(TagDto.fromMap).toList();
  }

  Future<TagDto?> getById(String id) async {
    final rows = await _dbHelper.rawQuery(
      'SELECT * FROM tags WHERE id = ?',
      [id],
    );
    if (rows.isEmpty) return null;
    return TagDto.fromMap(rows.first);
  }

  Future<TagDto?> getByName(String name) async {
    final rows = await _dbHelper.rawQuery(
      'SELECT * FROM tags WHERE name = ?',
      [name],
    );
    if (rows.isEmpty) return null;
    return TagDto.fromMap(rows.first);
  }

  Future<TagDto> insert(TagDto dto) async {
    _logger.info('TagLocalDataSource.insert', metadata: {'tagId': dto.id, 'name': dto.name});
    await _dbHelper.rawInsert(
      'INSERT INTO tags (id, name, color, created_at) VALUES (?, ?, ?, ?)',
      [dto.id, dto.name, dto.color, dto.createdAt],
    );
    return dto;
  }

  Future<TagDto?> update(TagDto dto) async {
    final count = await _dbHelper.rawUpdate(
      'UPDATE tags SET name = ?, color = ? WHERE id = ?',
      [dto.name, dto.color, dto.id],
    );
    if (count == 0) return null;
    return dto;
  }

  Future<int> delete(String id) async {
    _logger.info('TagLocalDataSource.delete', metadata: {'tagId': id});
    return _dbHelper.rawDelete('DELETE FROM tags WHERE id = ?', [id]);
  }

  Future<List<TagDto>> getByTaskId(String taskId) async {
    final rows = await _dbHelper.rawQuery(
      '''SELECT t.* FROM tags t
         INNER JOIN task_tags tt ON t.id = tt.tag_id
         WHERE tt.task_id = ?
         ORDER BY t.name ASC''',
      [taskId],
    );
    return rows.map(TagDto.fromMap).toList();
  }

  /// Link a tag to a task.
  Future<void> linkTask(String taskId, String tagId) async {
    _logger.info('TagLocalDataSource.linkTask', metadata: {'taskId': taskId, 'tagId': tagId});
    await _dbHelper.rawInsert(
      'INSERT OR IGNORE INTO task_tags (task_id, tag_id) VALUES (?, ?)',
      [taskId, tagId],
    );
  }

  /// Unlink a tag from a task.
  Future<void> unlinkTask(String taskId, String tagId) async {
    _logger.info('TagLocalDataSource.unlinkTask', metadata: {'taskId': taskId, 'tagId': tagId});
    await _dbHelper.rawDelete(
      'DELETE FROM task_tags WHERE task_id = ? AND tag_id = ?',
      [taskId, tagId],
    );
  }
}
