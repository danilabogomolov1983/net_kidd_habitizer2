import 'package:flutter_test/flutter_test.dart';
import 'package:net_kidd_habitizer2/features/task/domain/entities/task.dart';

void main() {
  group('Task entity', () {
    final sampleTask = Task(
      id: 't1',
      title: 'Buy groceries',
      description: 'Milk, eggs, bread',
      status: TaskStatus.todo,
      priority: TaskPriority.high,
      dueDate: DateTime(2026, 7, 1),
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    test('factory create sets defaults', () {
      final task = Task.create(id: 't2', title: 'Test task');
      expect(task.id, 't2');
      expect(task.title, 'Test task');
      expect(task.status, TaskStatus.todo);
      expect(task.priority, TaskPriority.medium);
      expect(task.description, isNull);
      expect(task.dueDate, isNull);
    });

    test('create sets provided values over defaults', () {
      final task = Task.create(
        id: 't3',
        title: 'Urgent',
        priority: TaskPriority.high,
        dueDate: DateTime(2026, 12, 31),
      );
      expect(task.priority, TaskPriority.high);
      expect(task.dueDate, DateTime(2026, 12, 31));
    });

    test('copyWith returns new instance with changed fields', () {
      final updated = sampleTask.copyWith(title: 'New title');
      expect(updated.title, 'New title');
      expect(updated.id, sampleTask.id);
      expect(updated.description, sampleTask.description);
    });

    test('copyWith can clear optional fields using function', () {
      final updated = sampleTask.copyWith(
        description: () => null,
        dueDate: () => null,
      );
      expect(updated.description, isNull);
      expect(updated.dueDate, isNull);
    });

    test('withStatus transitions status and updates timestamp', () {
      final started = sampleTask.withStatus(TaskStatus.inProgress);
      expect(started.status, TaskStatus.inProgress);
      expect(started.updatedAt.isAfter(sampleTask.updatedAt), true);
    });

    test('equality by value', () {
      final t1 = Task.create(id: 't1', title: 'Same');
      final t2 = Task.create(id: 't1', title: 'Same');
      // createdAt will differ, so they are not equal
      expect(t1, isNot(t2));
    });

    test('equatable props includes all fields', () {
      expect(sampleTask.props.length, 8);
    });

    test('TaskStatus enum values', () {
      expect(TaskStatus.values.length, 3);
      expect(TaskStatus.todo.name, 'todo');
      expect(TaskStatus.inProgress.name, 'inProgress');
      expect(TaskStatus.done.name, 'done');
    });

    test('TaskPriority enum values', () {
      expect(TaskPriority.values.length, 3);
    });
  });
}
