import 'package:flutter_test/flutter_test.dart';
import 'package:net_kidd_habitizer2/core/domain/result.dart';
import 'package:net_kidd_habitizer2/features/habit/domain/entities/habit_parameter.dart';
import 'package:net_kidd_habitizer2/features/habit/domain/failures.dart';
import 'package:net_kidd_habitizer2/features/habit/domain/repositories/habit_parameter_repository.dart';
import 'package:net_kidd_habitizer2/features/habit/application/services/habit_parameter_service.dart';

final class FakeRepo implements IHabitParameterRepository {
  final List<HabitParameter> _items = [];
  @override Future<Result<List<HabitParameter>>> getAll() async => Result.success(List.unmodifiable(_items));
  @override Future<Result<HabitParameter>> getById(String id) async {
    try { return Result.success(_items.firstWhere((p) => p.id == id)); }
    catch (_) { return Result.failure(HabitNotFoundFailure(id)); }
  }
  @override Future<Result<HabitParameter>> save(HabitParameter p) async {
    final idx = _items.indexWhere((x) => x.id == p.id);
    if (idx >= 0) _items[idx] = p; else _items.add(p);
    return Result.success(p);
  }
  @override Future<Result<void>> delete(String id) async {
    _items.removeWhere((p) => p.id == id);
    return Result.success(null);
  }
}

void main() {
  late FakeRepo repo;
  late HabitParameterService svc;

  setUp(() { repo = FakeRepo(); svc = HabitParameterService(repo); });

  test('create valid parameter', () async {
    final r = await svc.create(id: 'p1', type: 'fitness', description: 'Run', value: 5, unit: 'km');
    expect(r.isSuccess, true);
    expect(r.orNull!.description, 'Run');
    expect(r.orNull!.value, 5);
  });

  test('fails with empty description', () async {
    final r = await svc.create(id: 'p2', type: 'health', description: '  ', value: 1, unit: 'kg');
    expect(r.isFailure, true);
  });

  test('fails with empty type', () async {
    final r = await svc.create(id: 'p3', type: '', description: 'Test', value: 1, unit: 'kg');
    expect(r.isFailure, true);
  });

  test('fails with empty unit', () async {
    final r = await svc.create(id: 'p4', type: 'sleep', description: 'Test', value: 1, unit: '');
    expect(r.isFailure, true);
  });

  test('creates with dates', () async {
    final start = DateTime(2026, 1, 1);
    final end = DateTime(2026, 6, 30);
    final r = await svc.create(id: 'p5', type: 'fitness', description: 'Swim',
        startDate: start, endDate: end, value: 30, unit: 'min');
    expect(r.isSuccess, true);
    expect(r.orNull!.startDate, start);
    expect(r.orNull!.endDate, end);
  });

  test('update changes fields', () async {
    final created = await svc.create(id: 'p6', type: 'food', description: 'Old', value: 1, unit: 'bowl');
    final updated = created.orNull!.copyWith(description: 'New', value: 2);
    final r = await svc.update(updated);
    expect(r.isSuccess, true);
    expect(r.orNull!.description, 'New');
    expect(r.orNull!.value, 2);
  });

  test('delete removes parameter', () async {
    await svc.create(id: 'p7', type: 'sleep', description: 'Nap', value: 1, unit: 'h');
    final r = await svc.delete('p7');
    expect(r.isSuccess, true);
    final all = await svc.getAll();
    expect(all.orNull, isEmpty);
  });
}
