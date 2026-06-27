import 'package:flutter_test/flutter_test.dart';
import 'package:net_kidd_habitizer2/features/habit/domain/entities/habit.dart';

void main() {
  group('Habit entity', () {
    test('factory create sets id, type, name, createdAt', () {
      final habit = Habit.create(id: 'h1', type: 'daily', name: 'Morning workout');
      expect(habit.id, 'h1');
      expect(habit.type, 'daily');
      expect(habit.name, 'Morning workout');
      expect(habit.createdAt, isA<DateTime>());
    });

    test('copyWith returns new instance', () {
      final habit = Habit.create(id: 'h2', type: 'weekly', name: 'Reading');
      final updated = habit.copyWith(name: 'Book reading', type: 'daily');
      expect(updated.name, 'Book reading');
      expect(updated.type, 'daily');
      expect(updated.id, habit.id);
      expect(updated.createdAt, habit.createdAt);
    });

    test('equatable props', () {
      final habit = Habit.create(id: 'h3', type: 'counter', name: 'Water');
      expect(habit.props.length, 4);
    });
  });
}
