import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/infrastructure/database/database_module.dart';
import '../../domain/entities/habit_parameter.dart';
import '../../domain/repositories/habit_parameter_repository.dart';
import '../../domain/failures.dart';
import '../../application/dtos/habit_parameter_dto.dart';
import '../data_sources/habit_parameter_local_data_source.dart';

final class HabitParameterRepositoryImpl implements IHabitParameterRepository {
  final HabitParameterLocalDataSource _ds;

  HabitParameterRepositoryImpl(this._ds);

  @override
  Future<Result<List<HabitParameter>>> getAll() async {
    try {
      final dtos = await _ds.getAll();
      return Result.success(dtos.map(paramFromDto).toList());
    } catch (e, s) {
      return Result.failure(HabitPersistenceFailure('Failed to load: $e', s));
    }
  }

  @override
  Future<Result<HabitParameter>> getById(String id) async {
    try {
      final dto = await _ds.getById(id);
      if (dto == null) return Result.failure(HabitNotFoundFailure(id));
      return Result.success(paramFromDto(dto));
    } catch (e, s) {
      return Result.failure(HabitPersistenceFailure('Failed to load #$id: $e', s));
    }
  }

  @override
  Future<Result<HabitParameter>> save(HabitParameter param) async {
    try {
      final isNew = (await _ds.getById(param.id)) == null;
      final dto = paramToDto(param);
      final saved = isNew ? await _ds.insert(dto) : await _ds.update(dto);
      if (saved == null) return Result.failure(HabitNotFoundFailure(param.id));
      return Result.success(paramFromDto(saved));
    } catch (e, s) {
      return Result.failure(HabitPersistenceFailure('Failed to save: $e', s));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _ds.delete(id);
      return Result.success(null);
    } catch (e, s) {
      return Result.failure(HabitPersistenceFailure('Failed to delete #$id: $e', s));
    }
  }
}

final habitParameterRepositoryProvider = Provider<IHabitParameterRepository>((ref) {
  final dbHelper = ref.read(databaseHelperProvider);
  final ds = HabitParameterLocalDataSource(dbHelper);
  return HabitParameterRepositoryImpl(ds);
});
