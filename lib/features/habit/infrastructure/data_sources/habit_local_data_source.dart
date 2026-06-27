import '../../../../core/infrastructure/database/database_helper.dart';
import '../../../../core/infrastructure/logging/app_logger.dart';
import '../../../../core/infrastructure/logging/noop_logger.dart';
import '../../application/dtos/habit_dto.dart';
import '../../application/dtos/habit_parameter_dto.dart';

final class HabitLocalDataSource {
  final DatabaseHelper _dbHelper;
  final IAppLogger _logger;

  HabitLocalDataSource(this._dbHelper, {IAppLogger? logger})
      : _logger = logger ?? const NoOpLogger();

  // ── Habits ──────────────────────────────────────────────────────────

  Future<List<HabitDto>> getAllHabits() async {
    _logger.debug('HabitLocalDataSource.getAllHabits');
    final rows = await _dbHelper.rawQuery(
      'SELECT * FROM habits ORDER BY name ASC',
    );
    return rows.map(HabitDto.fromMap).toList();
  }

  Future<HabitDto?> getHabitById(String id) async {
    final rows = await _dbHelper.rawQuery(
      'SELECT * FROM habits WHERE id = ?',
      [id],
    );
    if (rows.isEmpty) return null;
    return HabitDto.fromMap(rows.first);
  }

  Future<HabitDto?> getHabitByName(String name) async {
    final rows = await _dbHelper.rawQuery(
      'SELECT * FROM habits WHERE name = ?',
      [name],
    );
    if (rows.isEmpty) return null;
    return HabitDto.fromMap(rows.first);
  }

  Future<HabitDto> insertHabit(HabitDto dto) async {
    _logger.info('HabitLocalDataSource.insertHabit',
        metadata: {'habitId': dto.id, 'name': dto.name});
    await _dbHelper.rawInsert(
      'INSERT INTO habits (id, type, name, created_at) VALUES (?, ?, ?, ?)',
      [dto.id, dto.type, dto.name, dto.createdAt],
    );
    return dto;
  }

  Future<HabitDto?> updateHabit(HabitDto dto) async {
    final count = await _dbHelper.rawUpdate(
      'UPDATE habits SET type = ?, name = ? WHERE id = ?',
      [dto.type, dto.name, dto.id],
    );
    if (count == 0) return null;
    return dto;
  }

  Future<int> deleteHabit(String id) async {
    _logger.info('HabitLocalDataSource.deleteHabit', metadata: {'habitId': id});
    // Also delete associated parameters.
    await _dbHelper.rawDelete(
      'DELETE FROM habit_parameters WHERE habit_id = ?',
      [id],
    );
    return _dbHelper.rawDelete('DELETE FROM habits WHERE id = ?', [id]);
  }

  // ── Habit Parameters ────────────────────────────────────────────────

  Future<List<HabitParameterDto>> getParametersByHabitId(String habitId) async {
    _logger.debug('HabitLocalDataSource.getParametersByHabitId',
        metadata: {'habitId': habitId});
    final rows = await _dbHelper.rawQuery(
      'SELECT * FROM habit_parameters WHERE habit_id = ? ORDER BY created_at DESC',
      [habitId],
    );
    return rows.map(HabitParameterDto.fromMap).toList();
  }

  Future<HabitParameterDto?> getParameterById(String id) async {
    final rows = await _dbHelper.rawQuery(
      'SELECT * FROM habit_parameters WHERE id = ?',
      [id],
    );
    if (rows.isEmpty) return null;
    return HabitParameterDto.fromMap(rows.first);
  }

  Future<HabitParameterDto> insertParameter(HabitParameterDto dto) async {
    _logger.info('HabitLocalDataSource.insertParameter',
        metadata: {'paramId': dto.id, 'habitId': dto.habitId});
    await _dbHelper.rawInsert(
      '''INSERT INTO habit_parameters (id, habit_id, start_date, end_date, value, measure_unit, created_at)
         VALUES (?, ?, ?, ?, ?, ?, ?)''',
      [
        dto.id,
        dto.habitId,
        dto.startDate,
        dto.endDate,
        dto.value,
        dto.measureUnit,
        dto.createdAt,
      ],
    );
    return dto;
  }

  Future<HabitParameterDto?> updateParameter(HabitParameterDto dto) async {
    final count = await _dbHelper.rawUpdate(
      '''UPDATE habit_parameters
         SET start_date = ?, end_date = ?, value = ?, measure_unit = ?
         WHERE id = ?''',
      [dto.startDate, dto.endDate, dto.value, dto.measureUnit, dto.id],
    );
    if (count == 0) return null;
    return dto;
  }

  Future<int> deleteParameter(String id) async {
    _logger.info('HabitLocalDataSource.deleteParameter',
        metadata: {'paramId': id});
    return _dbHelper.rawDelete(
      'DELETE FROM habit_parameters WHERE id = ?',
      [id],
    );
  }
}
