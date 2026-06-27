import 'package:flutter_test/flutter_test.dart';
import 'package:net_kidd_habitizer2/features/habit/domain/entities/habit_parameter.dart';

void main() {
  group('HabitParameter entity', () {
    test('factory create sets all fields', () {
      final param = HabitParameter.create(
        id: 'p1',
        habitId: 'h1',
        value: 30,
        measureUnit: 'minutes',
      );
      expect(param.id, 'p1');
      expect(param.habitId, 'h1');
      expect(param.value, 30);
      expect(param.measureUnit, 'minutes');
      expect(param.startDate, isNull);
      expect(param.endDate, isNull);
      expect(param.createdAt, isA<DateTime>());
    });

    test('create with date range', () {
      final start = DateTime(2026, 1, 1);
      final end = DateTime(2026, 12, 31);
      final param = HabitParameter.create(
        id: 'p2',
        habitId: 'h2',
        startDate: start,
        endDate: end,
        value: 5.5,
        measureUnit: 'km',
      );
      expect(param.startDate, start);
      expect(param.endDate, end);
    });

    test('copyWith updates individual fields', () {
      final param = HabitParameter.create(
        id: 'p3',
        habitId: 'h3',
        value: 10,
        measureUnit: 'reps',
      );
      final updated = param.copyWith(value: 20, measureUnit: 'sets');
      expect(updated.value, 20);
      expect(updated.measureUnit, 'sets');
      expect(updated.id, param.id);
      expect(updated.habitId, param.habitId);
    });

    test('equatable props', () {
      final param = HabitParameter.create(
        id: 'p4',
        habitId: 'h4',
        value: 1,
        measureUnit: 'glasses',
      );
      expect(param.props.length, 7);
    });
  });
}
