import 'package:flutter_test/flutter_test.dart';
import 'package:net_kidd_habitizer2/core/domain/result.dart';
import 'package:net_kidd_habitizer2/features/habit/domain/entities/habit.dart';
import 'package:net_kidd_habitizer2/features/habit/domain/entities/habit_parameter.dart';
import 'package:net_kidd_habitizer2/features/habit/domain/failures.dart';
import 'package:net_kidd_habitizer2/features/habit/domain/repositories/habit_repository.dart';
import 'package:net_kidd_habitizer2/features/habit/application/services/habit_service.dart';

final class FakeHabitRepository implements IHabitRepository {
  final List<Habit> _habits = [];
  final List<HabitParameter> _parameters = [];

  @override
  Future<Result<List<Habit>>> getAllHabits() async =>
      Result.success(List.unmodifiable(_habits));

  @override
  Future<Result<Habit>> getHabitById(String id) async {
    try {
      return Result.success(_habits.firstWhere((h) => h.id == id));
    } catch (_) {
      return Result.failure(HabitNotFoundFailure(id));
    }
  }

  @override
  Future<Result<Habit>> getHabitByName(String name) async {
    try {
      return Result.success(_habits.firstWhere((h) => h.name == name));
    } catch (_) {
      return Result.failure(HabitNotFoundFailure(name));
    }
  }

  @override
  Future<Result<Habit>> saveHabit(Habit habit) async {
    final idx = _habits.indexWhere((h) => h.id == habit.id);
    if (idx >= 0) {
      _habits[idx] = habit;
    } else {
      _habits.add(habit);
    }
    return Result.success(habit);
  }

  @override
  Future<Result<void>> deleteHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    _parameters.removeWhere((p) => p.habitId == id);
    return Result.success(null);
  }

  @override
  Future<Result<List<HabitParameter>>> getParametersByHabitId(
      String habitId) async {
    return Result.success(
      _parameters.where((p) => p.habitId == habitId).toList(),
    );
  }

  @override
  Future<Result<HabitParameter>> getParameterById(String id) async {
    try {
      return Result.success(_parameters.firstWhere((p) => p.id == id));
    } catch (_) {
      return Result.failure(HabitNotFoundFailure(id));
    }
  }

  @override
  Future<Result<HabitParameter>> saveParameter(
      HabitParameter parameter) async {
    final idx = _parameters.indexWhere((p) => p.id == parameter.id);
    if (idx >= 0) {
      _parameters[idx] = parameter;
    } else {
      _parameters.add(parameter);
    }
    return Result.success(parameter);
  }

  @override
  Future<Result<void>> deleteParameter(String id) async {
    _parameters.removeWhere((p) => p.id == id);
    return Result.success(null);
  }
}

void main() {
  late FakeHabitRepository repository;
  late HabitService service;

  setUp(() {
    repository = FakeHabitRepository();
    service = HabitService(repository);
  });

  group('HabitService — Habits', () {
    group('createHabit', () {
      test('creates a valid habit', () async {
        final result = await service.createHabit(
            id: 'h1', type: 'daily', name: 'Exercise');
        expect(result.isSuccess, true);
        expect(result.orNull!.name, 'Exercise');
        expect(result.orNull!.type, 'daily');
      });

      test('trims whitespace in name and type', () async {
        final result = await service.createHabit(
            id: 'h2', type: '  daily  ', name: '  Run  ');
        expect(result.orNull!.name, 'Run');
        expect(result.orNull!.type, 'daily');
      });

      test('fails with empty name', () async {
        final result =
            await service.createHabit(id: 'h3', type: 'daily', name: '   ');
        expect(result.isFailure, true);
        expect(result.failureOrNull, isA<HabitValidationFailure>());
      });

      test('fails with empty type', () async {
        final result =
            await service.createHabit(id: 'h4', type: '', name: 'Test');
        expect(result.isFailure, true);
        expect(result.failureOrNull, isA<HabitValidationFailure>());
      });

      test('fails with name over 100 chars', () async {
        final result = await service.createHabit(
            id: 'h5', type: 'daily', name: 'a' * 101);
        expect(result.isFailure, true);
      });

      test('fails with type over 30 chars', () async {
        final result = await service.createHabit(
            id: 'h6', type: 'a' * 31, name: 'Test');
        expect(result.isFailure, true);
      });

      test('fails on duplicate name', () async {
        await service.createHabit(id: 'h7', type: 'daily', name: 'Meditate');
        final result =
            await service.createHabit(id: 'h8', type: 'daily', name: 'Meditate');
        expect(result.isFailure, true);
        expect(result.failureOrNull, isA<HabitDuplicateFailure>());
      });
    });

    group('updateHabit', () {
      test('updates an existing habit', () async {
        final created = await service.createHabit(
            id: 'h9', type: 'weekly', name: 'Old');
        final updated = created.orNull!.copyWith(
            name: 'New', type: 'monthly');
        final result = await service.updateHabit(updated);
        expect(result.isSuccess, true);
        expect(result.orNull!.name, 'New');
        expect(result.orNull!.type, 'monthly');
      });
    });

    group('deleteHabit', () {
      test('removes the habit', () async {
        await service.createHabit(id: 'h10', type: 'counter', name: 'Temp');
        final result = await service.deleteHabit('h10');
        expect(result.isSuccess, true);
        final all = await service.getAllHabits();
        expect(all.orNull, isEmpty);
      });
    });
  });

  group('HabitService — Parameters', () {
    test('createParameter adds a parameter', () async {
      final result = await service.createParameter(
        id: 'p1',
        habitId: 'h1',
        value: 30,
        measureUnit: 'minutes',
      );
      expect(result.isSuccess, true);
      expect(result.orNull!.value, 30);
      expect(result.orNull!.measureUnit, 'minutes');
    });

    test('createParameter with date range', () async {
      final start = DateTime(2026, 1, 1);
      final end = DateTime(2026, 6, 30);
      final result = await service.createParameter(
        id: 'p2',
        habitId: 'h1',
        startDate: start,
        endDate: end,
        value: 5,
        measureUnit: 'km',
      );
      expect(result.isSuccess, true);
      expect(result.orNull!.startDate, start);
      expect(result.orNull!.endDate, end);
    });

    test('fails with empty measure unit', () async {
      final result = await service.createParameter(
        id: 'p3',
        habitId: 'h1',
        value: 10,
        measureUnit: '   ',
      );
      expect(result.isFailure, true);
      expect(result.failureOrNull, isA<HabitValidationFailure>());
    });

    test('fails with measure unit over 20 chars', () async {
      final result = await service.createParameter(
        id: 'p4',
        habitId: 'h1',
        value: 1,
        measureUnit: 'a' * 21,
      );
      expect(result.isFailure, true);
    });

    test('updateParameter modifies parameter', () async {
      final created = await service.createParameter(
        id: 'p5',
        habitId: 'h1',
        value: 10,
        measureUnit: 'reps',
      );
      final updated = created.orNull!.copyWith(value: 15);
      final result = await service.updateParameter(updated);
      expect(result.isSuccess, true);
      expect(result.orNull!.value, 15);
    });

    test('deleteParameter removes parameter', () async {
      await service.createParameter(
        id: 'p6',
        habitId: 'h1',
        value: 8,
        measureUnit: 'glasses',
      );
      final result = await service.deleteParameter('p6');
      expect(result.isSuccess, true);
      final params = await service.getParametersByHabitId('h1');
      expect(params.orNull, isEmpty);
    });

    test('getParametersByHabitId returns only matching params', () async {
      await service.createParameter(
        id: 'p7', habitId: 'h1', value: 1, measureUnit: 'kg');
      await service.createParameter(
        id: 'p8', habitId: 'h2', value: 2, measureUnit: 'kg');
      final h1Params = await service.getParametersByHabitId('h1');
      expect(h1Params.orNull!.length, 1);
      expect(h1Params.orNull!.first.id, 'p7');
    });
  });
}
