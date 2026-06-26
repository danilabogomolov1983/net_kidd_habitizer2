import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/services/task_service.dart';
import '../../domain/entities/task.dart';

/// Reactive notifier for task list state.
///
/// Wraps [TaskService] calls into a [Notifier] so that the UI layer
/// can react to loading / error / data states via Riverpod.
final class TaskNotifier extends Notifier<AsyncValue<List<Task>>> {
  @override
  AsyncValue<List<Task>> build() {
    loadTasks();
    return const AsyncValue.loading();
  }

  Future<void> loadTasks() async {
    state = const AsyncValue.loading();
    final service = ref.read(taskServiceProvider);
    final result = await service.getAllTasks();
    state = result.fold(
      (f) => AsyncValue.error(f, StackTrace.current),
      (tasks) => AsyncValue.data(tasks),
    );
  }

  Future<void> createTask({
    required String id,
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
  }) async {
    final service = ref.read(taskServiceProvider);
    await service.createTask(
      id: id,
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
    );
    await loadTasks();
  }

  Future<void> completeTask(String id) async {
    final service = ref.read(taskServiceProvider);
    await service.completeTask(id);
    await loadTasks();
  }

  Future<void> startTask(String id) async {
    final service = ref.read(taskServiceProvider);
    await service.startTask(id);
    await loadTasks();
  }

  Future<void> deleteTask(String id) async {
    final service = ref.read(taskServiceProvider);
    await service.deleteTask(id);
    await loadTasks();
  }

  Future<void> filterByStatus(TaskStatus? status) async {
    if (status == null) {
      await loadTasks();
      return;
    }
    state = const AsyncValue.loading();
    final service = ref.read(taskServiceProvider);
    final result = await service.getTasksByStatus(status);
    state = result.fold(
      (f) => AsyncValue.error(f, StackTrace.current),
      (tasks) => AsyncValue.data(tasks),
    );
  }
}

/// Riverpod provider for [TaskNotifier].
final taskNotifierProvider = NotifierProvider<TaskNotifier, AsyncValue<List<Task>>>(
  TaskNotifier.new,
);
