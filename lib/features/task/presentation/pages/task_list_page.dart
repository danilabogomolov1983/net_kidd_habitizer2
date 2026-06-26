import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task.dart';
import '../state/task_notifier.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form.dart';

/// Main page displaying the list of tasks.
///
/// Uses Riverpod's [taskNotifierProvider] for reactive state management.
/// Tapping the FAB opens a [TaskForm] bottom sheet.
final class TaskListPage extends ConsumerWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskNotifierProvider);
    final notifier = ref.read(taskNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          PopupMenuButton<TaskStatus?>(
            tooltip: 'Filter by status',
            icon: const Icon(Icons.filter_list),
            onSelected: (status) => notifier.filterByStatus(status),
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('All')),
              ...TaskStatus.values.map(
                (s) => PopupMenuItem(value: s, child: Text(s.name)),
              ),
            ],
          ),
        ],
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 8),
              Text('Error: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => notifier.loadTasks(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (tasks) {
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.task_alt, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create your first task',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => notifier.loadTasks(),
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskCard(
                  task: task,
                  onTap: () {
                    // Future: navigate to detail / edit
                  },
                  onComplete: () => notifier.completeTask(task.id),
                  onDelete: () => _confirmDelete(context, task, notifier),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateForm(context, notifier),
        tooltip: 'New Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateForm(BuildContext context, TaskNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => TaskForm(
        onSubmit: (id, title, desc, priority, dueDate) {
          notifier.createTask(
            id: id,
            title: title,
            description: desc,
            priority: priority,
            dueDate: dueDate,
          );
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Task task, TaskNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              notifier.deleteTask(task.id);
              Navigator.of(ctx).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
