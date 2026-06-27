import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/infrastructure/database/database_module.dart';
import '../../../../core/infrastructure/logging/logging_module.dart';
import '../../../../core/infrastructure/logging/app_logger.dart';
import '../../../../core/infrastructure/logging/noop_logger.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_parameter.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/failures.dart';
import '../../application/dtos/habit_dto.dart';
import '../../application/dtos/habit_parameter_dto.dart';
import '../data_sources/habit_local_data_source.dart';

final class HabitRepositoryImpl implements IHabitRepository {
  final HabitLocalDataSource _dataSource;
  final IAppLogger _logger;

  HabitRepositoryImpl(this._dataSource, {IAppLogger? logger})
      : _logger = logger ?? const NoOpLogger();

  // ── Habits ──────────────────────────────────────────────────────────

  @override
  Future<Result<List<Habit>>> getAllHabits() async {
    try {
      final dtos = await _dataSource.getAllHabits();
      final habits = dtos.map(habitFromDto).toList();
      _logger.debug('HabitRepositoryImpl.getAllHabits',
          metadata: {'count': habits.length});
      return Result.success(habits);
    } catch (e, s) {
      _logger.error('Failed to load habits', errorObject: e, stackTrace: s);
      return Result.failure(HabitPersistenceFailure('Failed to load habits: $e', s));
    }
  }

  @override
  Future<Result<Habit>> getHabitById(String id) async {
    try {
      final dto = await _dataSource.getHabitById(id);
      if (dto == null) return Result.failure(HabitNotFoundFailure(id));
      return Result.success(habitFromDto(dto));
    } catch (e, s) {
      return Result.failure(
          HabitPersistenceFailure('Failed to load habit#$id: $e', s));
    }
  }

  @override
  Future<Result<Habit>> getHabitByName(String name) async {
    try {
      final dto = await _dataSource.getHabitByName(name);
      if (dto == null) return Result.failure(HabitNotFoundFailure(name));
      return Result.success(habitFromDto(dto));
    } catch (e, s) {
      return Result.failure(
          HabitPersistenceFailure('Failed to load habit by name: $e', s));
    }
  }

  @override
  Future<Result<Habit>> saveHabit(Habit habit) async {
    try {
      final isNew = (await _dataSource.getHabitById(habit.id)) == null;
      final dto = habitToDto(habit);
      final savedDto =
          isNew ? await _dataSource.insertHabit(dto) : await _dataSource.updateHabit(dto);
      if (savedDto == null) return Result.failure(HabitNotFoundFailure(habit.id));
      _logger.info('Habit saved',
          metadata: {'habitId': habit.id, 'name': habit.name, 'isNew': isNew});
      return Result.success(habitFromDto(savedDto));
    } catch (e, s) {
      _logger.error('Failed to save habit',
          metadata: {'habitId': habit.id}, errorObject: e, stackTrace: s);
      return Result.failure(HabitPersistenceFailure('Failed to save habit: $e', s));
    }
  }

  @override
  Future<Result<void>> deleteHabit(String id) async {
    try {
      await _dataSource.deleteHabit(id);
      _logger.info('Habit deleted', metadata: {'habitId': id});
      return Result.success(null);
    } catch (e, s) {
      _logger.error('Failed to delete habit',
          metadata: {'habitId': id}, errorObject: e, stackTrace: s);
      return Result.failure(
          HabitPersistenceFailure('Failed to delete habit#$id: $e', s));
    }
  }

  // ── Habit Parameters ────────────────────────────────────────────────

  @override
  Future<Result<List<HabitParameter>>> getParametersByHabitId(
      String habitId) async {
    try {
      final dtos = await _dataSource.getParametersByHabitId(habitId);
      return Result.success(dtos.map(habitParameterFromDto).toList());
    } catch (e, s) {
      return Result.failure(HabitPersistenceFailure(
          'Failed to load parameters for habit: $e', s));
    }
  }

  @override
  Future<Result<HabitParameter>> getParameterById(String id) async {
    try {
      final dto = await _dataSource.getParameterById(id);
      if (dto == null) return Result.failure(HabitNotFoundFailure(id));
      return Result.success(habitParameterFromDto(dto));
    } catch (e, s) {
      return Result.failure(
          HabitPersistenceFailure('Failed to load parameter#$id: $e', s));
    }
  }

  @override
  Future<Result<HabitParameter>> saveParameter(
      HabitParameter parameter) async {
    try {
      final isNew =
          (await _dataSource.getParameterById(parameter.id)) == null;
      final dto = habitParameterToDto(parameter);
      final savedDto = isNew
          ? await _dataSource.insertParameter(dto)
          : await _dataSource.updateParameter(dto);
      if (savedDto == null) {
        return Result.failure(HabitNotFoundFailure(parameter.id));
      }
      _logger.info('Parameter saved',
          metadata: {'paramId': parameter.id, 'isNew': isNew});
      return Result.success(habitParameterFromDto(savedDto));
    } catch (e, s) {
      _logger.error('Failed to save parameter',
          metadata: {'paramId': parameter.id}, errorObject: e, stackTrace: s);
      return Result.failure(
          HabitPersistenceFailure('Failed to save parameter: $e', s));
    }
  }

  @override
  Future<Result<void>> deleteParameter(String id) async {
    try {
      await _dataSource.deleteParameter(id);
      _logger.info('Parameter deleted', metadata: {'paramId': id});
      return Result.success(null);
    } catch (e, s) {
      _logger.error('Failed to delete parameter',
          metadata: {'paramId': id}, errorObject: e, stackTrace: s);
      return Result.failure(
          HabitPersistenceFailure('Failed to delete parameter#$id: $e', s));
    }
  }
}

final habitRepositoryProvider = Provider<IHabitRepository>((ref) {
  final dbHelper = ref.read(databaseHelperProvider);
  final logger = ref.read(appLoggerProvider);
  final dataSource = HabitLocalDataSource(dbHelper, logger: logger);
  return HabitRepositoryImpl(dataSource, logger: logger);
});

final habitLocalDataSourceProvider = Provider<HabitLocalDataSource>((ref) {
  final dbHelper = ref.read(databaseHelperProvider);
  final logger = ref.read(appLoggerProvider);
  return HabitLocalDataSource(dbHelper, logger: logger);
});
