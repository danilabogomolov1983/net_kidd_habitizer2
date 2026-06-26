import 'package:flutter_test/flutter_test.dart';
import 'package:net_kidd_habitizer2/core/domain/result.dart';
import 'package:net_kidd_habitizer2/features/task/domain/entities/task.dart';
import 'package:net_kidd_habitizer2/features/task/domain/failures.dart';
import 'package:net_kidd_habitizer2/features/task/domain/repositories/task_repository.dart';
import 'package:net_kidd_habitizer2/features/task/application/services/task_service.dart';

/// In-memory fake repository for testing [TaskService].
final class FakeTaskRepository implements ITaskRepository {
  final List<Task> _tasks = [];

  @override
  Future<Result<List<Task>>> getAll() async => Result.success(List.unmodifiable(_tasks));

  @override
  Future<Result<Task>> getById(String id) async {
    try {
      final task = _tasks.firstWhere((t) => t.id == id);
      return Result.success(task);
    } catch (_) {
      return Result.failure(TaskNotFoundFailure(id));
    }
  }

  @override
  Future<Result<List<Task>>> getByStatus(TaskStatus status) async {
    final filtered = _tasks.where((t) => t.status == status).toList();
    return Result.success(filtered);
  }

  @override
  Future<Result<Task>> save(Task task) async {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx >= 0) {
      _tasks[idx] = task;
    } else {
      _tasks.add(task);
    }
    return Result.success(task);
  }

  @override
  Future<Result<void>> delete(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    return Result.success(null);
  }

  @override
  Future<Result<List<Task>>> getByTagId(String tagId) async {
    return Result.success([]);
  }
}

void main() {
  late FakeTaskRepository repository;
  late TaskService service;

  setUp(() {
    repository = FakeTaskRepository();
    service = TaskService(repository);
  });

  group('TaskService', () {
    group('createTask', () {
      test('creates a valid task', () async {
        final result = await service.createTask(
          id: 't1',
          title: 'Exercise',
          priority: TaskPriority.high,
        );
        expect(result.isSuccess, true);
        expect(result.orNull!.title, 'Exercise');
        expect(result.orNull!.priority, TaskPriority.high);
      });

      test('trims whitespace from title', () async {
        final result = await service.createTask(id: 't2', title: '  Hello  ');
        expect(result.orNull!.title, 'Hello');
      });

      test('fails with empty title', () async {
        final result = await service.createTask(id: 't3', title: '   ');
        expect(result.isFailure, true);
        expect(result.failureOrNull, isA<TaskValidationFailure>());
      });

      test('fails with title over 100 characters', () async {
        final longTitle = 'a' * 101;
        final result = await service.createTask(id: 't4', title: longTitle);
        expect(result.isFailure, true);
        final f = result.failureOrNull as TaskValidationFailure;
        expect(f.field, 'title');
      });
    });

    group('completeTask', () {
      test('transitions task to done', () async {
        await service.createTask(id: 't5', title: 'Write tests');
        final result = await service.completeTask('t5');
        expect(result.isSuccess, true);
        expect(result.orNull!.status, TaskStatus.done);
      });

      test('fails when task not found', () async {
        final result = await service.completeTask('nonexistent');
        expect(result.isFailure, true);
      });
    });

    group('startTask', () {
      test('transitions task to inProgress', () async {
        await service.createTask(id: 't6', title: 'Start me');
        final result = await service.startTask('t6');
        expect(result.isSuccess, true);
        expect(result.orNull!.status, TaskStatus.inProgress);
      });
    });

    group('updateTask', () {
      test('updates an existing task', () async {
        final created = await service.createTask(id: 't7', title: 'Original');
        final updated = created.orNull!.copyWith(title: 'Updated');
        final result = await service.updateTask(updated);
        expect(result.isSuccess, true);
        expect(result.orNull!.title, 'Updated');
      });

      test('rejects empty title on update', () async {
        final created = await service.createTask(id: 't8', title: 'Valid');
        final updated = created.orNull!.copyWith(title: '   ');
        final result = await service.updateTask(updated);
        expect(result.isFailure, true);
      });
    });

    group('deleteTask', () {
      test('deletes an existing task', () async {
        await service.createTask(id: 't9', title: 'To delete');
        final result = await service.deleteTask('t9');
        expect(result.isSuccess, true);

        final getResult = await service.getAllTasks();
        expect(getResult.orNull!.length, 0);
      });
    });

    group('getAllTasks', () {
      test('returns empty list initially', () async {
        final result = await service.getAllTasks();
        expect(result.orNull, isEmpty);
      });

      test('returns all created tasks', () async {
        await service.createTask(id: 'a1', title: 'Task A');
        await service.createTask(id: 'a2', title: 'Task B');
        final result = await service.getAllTasks();
        expect(result.orNull!.length, 2);
      });
    });
  });
}
