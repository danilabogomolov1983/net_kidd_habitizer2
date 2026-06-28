import '../../../../core/infrastructure/database/database_helper.dart';
import '../../application/dtos/habit_parameter_dto.dart';

final class HabitParameterLocalDataSource {
  final DatabaseHelper _dbHelper;

  HabitParameterLocalDataSource(this._dbHelper);

  Future<List<HabitParameterDto>> getAll() async {
    final rows = await _dbHelper.rawQuery(
      'SELECT * FROM habits ORDER BY description ASC',
    );
    return rows.map(HabitParameterDto.fromMap).toList();
  }

  Future<HabitParameterDto?> getById(String id) async {
    final rows = await _dbHelper.rawQuery(
      'SELECT * FROM habits WHERE id = ?', [id],
    );
    if (rows.isEmpty) return null;
    return HabitParameterDto.fromMap(rows.first);
  }

  Future<HabitParameterDto> insert(HabitParameterDto dto) async {
    await _dbHelper.rawInsert(
      '''INSERT INTO habits (id, type, description, start_date, end_date, value, unit, created_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
      [dto.id, dto.type, dto.description, dto.startDate, dto.endDate, dto.value, dto.unit, dto.createdAt],
    );
    return dto;
  }

  Future<HabitParameterDto?> update(HabitParameterDto dto) async {
    final count = await _dbHelper.rawUpdate(
      '''UPDATE habits SET type = ?, description = ?, start_date = ?, end_date = ?,
         value = ?, unit = ? WHERE id = ?''',
      [dto.type, dto.description, dto.startDate, dto.endDate, dto.value, dto.unit, dto.id],
    );
    if (count == 0) return null;
    return dto;
  }

  Future<int> delete(String id) async {
    return _dbHelper.rawDelete('DELETE FROM habits WHERE id = ?', [id]);
  }
}
