import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/infrastructure/logging/logging_module.dart';
import '../../../../core/infrastructure/logging/app_logger.dart';
import '../../../../core/infrastructure/logging/noop_logger.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_parameter.dart';
import '../../domain/failures.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../infrastructure/repositories/habit_repository_impl.dart';

final class HabitService {
  final IHabitRepository _repository;
  final IAppLogger _logger;

  HabitService(this._repository, {IAppLogger? logger})
      : _logger = logger ?? const NoOpLogger();

  // ── Habits ──────────────────────────────────────────────────────────

  Future<Result<Habit>> createHabit({
    required String id,
    required String type,
    required String name,
  }) async {
    final nameResult = _validateName(name);
    if (nameResult.isFailure) {
      _logger.warning('HabitService.createHabit validation failed',
          metadata: {'field': 'name', 'value': name});
      return Result<Habit>.failure(nameResult.failureOrNull!);
    }

    final typeResult = _validateType(type);
    if (typeResult.isFailure) {
      _logger.warning('HabitService.createHabit validation failed',
          metadata: {'field': 'type', 'value': type});
      return Result<Habit>.failure(typeResult.failureOrNull!);
    }

    final trimmed = name.trim();
    final existing = await _repository.getHabitByName(trimmed);
    if (existing.isSuccess) {
      _logger.warning('HabitService.createHabit duplicate',
          metadata: {'name': trimmed});
      return Result.failure(HabitDuplicateFailure(trimmed));
    }

    final habit = Habit.create(id: id, type: type.trim(), name: trimmed);
    _logger.info('HabitService.createHabit',
        metadata: {'habitId': id, 'name': trimmed, 'type': type.trim()});
    return _repository.saveHabit(habit);
  }

  Future<Result<List<Habit>>> getAllHabits() {
    _logger.debug('HabitService.getAllHabits');
    return _repository.getAllHabits();
  }

  Future<Result<Habit>> getHabitById(String id) =>
      _repository.getHabitById(id);

  Future<Result<Habit>> updateHabit(Habit updated) async {
    final nameResult = _validateName(updated.name);
    if (nameResult.isFailure) {
      _logger.warning('HabitService.updateHabit validation failed',
          metadata: {'habitId': updated.id, 'field': 'name'});
      return Result<Habit>.failure(nameResult.failureOrNull!);
    }
    final typeResult = _validateType(updated.type);
    if (typeResult.isFailure) {
      _logger.warning('HabitService.updateHabit validation failed',
          metadata: {'habitId': updated.id, 'field': 'type'});
      return Result<Habit>.failure(typeResult.failureOrNull!);
    }
    _logger.info('HabitService.updateHabit',
        metadata: {'habitId': updated.id});
    return _repository.saveHabit(updated);
  }

  Future<Result<void>> deleteHabit(String id) {
    _logger.info('HabitService.deleteHabit', metadata: {'habitId': id});
    return _repository.deleteHabit(id);
  }

  // ── Habit Parameters ────────────────────────────────────────────────

  Future<Result<List<HabitParameter>>> getParametersByHabitId(
          String habitId) {
    _logger.debug('HabitService.getParametersByHabitId',
        metadata: {'habitId': habitId});
    return _repository.getParametersByHabitId(habitId);
  }

  Future<Result<HabitParameter>> createParameter({
    required String id,
    required String habitId,
    DateTime? startDate,
    DateTime? endDate,
    required double value,
    required String measureUnit,
  }) async {
    final unitResult = _validateMeasureUnit(measureUnit);
    if (unitResult.isFailure) {
      _logger.warning('HabitService.createParameter validation failed',
          metadata: {'field': 'measureUnit', 'value': measureUnit});
      return Result<HabitParameter>.failure(unitResult.failureOrNull!);
    }

    final param = HabitParameter.create(
      id: id,
      habitId: habitId,
      startDate: startDate,
      endDate: endDate,
      value: value,
      measureUnit: measureUnit.trim(),
    );
    _logger.info('HabitService.createParameter',
        metadata: {'paramId': id, 'habitId': habitId});
    return _repository.saveParameter(param);
  }

  Future<Result<HabitParameter>> updateParameter(
      HabitParameter updated) async {
    final unitResult = _validateMeasureUnit(updated.measureUnit);
    if (unitResult.isFailure) {
      _logger.warning('HabitService.updateParameter validation failed',
          metadata: {'paramId': updated.id, 'field': 'measureUnit'});
      return Result<HabitParameter>.failure(unitResult.failureOrNull!);
    }
    _logger.info('HabitService.updateParameter',
        metadata: {'paramId': updated.id});
    return _repository.saveParameter(updated);
  }

  Future<Result<void>> deleteParameter(String id) {
    _logger.info('HabitService.deleteParameter', metadata: {'paramId': id});
    return _repository.deleteParameter(id);
  }

  // ── Validators ──────────────────────────────────────────────────────

  Result<String> _validateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return Result<String>.failure(const HabitValidationFailure(
          field: 'name', message: 'Habit name must not be empty'));
    }
    if (trimmed.length > 100) {
      return Result<String>.failure(const HabitValidationFailure(
          field: 'name',
          message: 'Habit name must be 100 characters or fewer'));
    }
    return Result.success(trimmed);
  }

  Result<String> _validateType(String type) {
    final trimmed = type.trim();
    if (trimmed.isEmpty) {
      return Result<String>.failure(const HabitValidationFailure(
          field: 'type', message: 'Habit type must not be empty'));
    }
    if (trimmed.length > 30) {
      return Result<String>.failure(const HabitValidationFailure(
          field: 'type',
          message: 'Habit type must be 30 characters or fewer'));
    }
    return Result.success(trimmed);
  }

  Result<String> _validateMeasureUnit(String unit) {
    final trimmed = unit.trim();
    if (trimmed.isEmpty) {
      return Result<String>.failure(const HabitValidationFailure(
          field: 'measureUnit', message: 'Measure unit must not be empty'));
    }
    if (trimmed.length > 20) {
      return Result<String>.failure(const HabitValidationFailure(
          field: 'measureUnit',
          message: 'Measure unit must be 20 characters or fewer'));
    }
    return Result.success(trimmed);
  }
}

final habitServiceProvider = Provider<HabitService>((ref) {
  final repository = ref.read(habitRepositoryProvider);
  final logger = ref.read(appLoggerProvider);
  return HabitService(repository, logger: logger);
});
