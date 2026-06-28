import 'package:flutter_test/flutter_test.dart';
import 'package:net_kidd_habitizer2/features/habit/domain/entities/habit_parameter.dart';

void main() {
  group('HabitParameter', () {
    test('factory create sets all fields', () {
      final p = HabitParameter.create(
        id: 'h1', type: 'fitness', description: 'Morning workout',
        value: 30, unit: 'min',
      );
      expect(p.id, 'h1');
      expect(p.type, 'fitness');
      expect(p.description, 'Morning workout');
      expect(p.value, 30);
      expect(p.unit, 'min');
      expect(p.createdAt, isA<DateTime>());
    });

    test('copyWith returns new instance', () {
      final p = HabitParameter.create(
        id: 'h2', type: 'food', description: 'Reading', value: 5, unit: 'pages',
      );
      final updated = p.copyWith(description: 'Book', type: 'health', value: 10);
      expect(updated.description, 'Book');
      expect(updated.type, 'health');
      expect(updated.value, 10);
      expect(updated.id, p.id);
    });

    test('equatable props', () {
      final p = HabitParameter.create(
        id: 'h3', type: 'sleep', description: 'Sleep', value: 8, unit: 'hours',
      );
      expect(p.props.length, 8);
    });
  });
}
