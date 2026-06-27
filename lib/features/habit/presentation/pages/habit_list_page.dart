import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_parameter.dart';
import '../state/habit_notifier.dart';
import '../widgets/habit_card.dart';
import 'habit_detail_page.dart';

final class HabitListPage extends ConsumerWidget {
  const HabitListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitNotifierProvider);
    final notifier = ref.read(habitNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Habits')),
      body: habitsAsync.when(
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
                onPressed: () => notifier.loadHabits(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (habits) {
          if (habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.self_improvement,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No habits yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => notifier.loadHabits(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return _HabitListItem(
                  habit: habit,
                  onDelete: () => _confirmDelete(context, notifier, habit),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HabitDetailPage()),
        ),
        tooltip: 'New Habit',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, HabitNotifier notifier, habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Delete "${habit.name}" and all its parameters?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              notifier.deleteHabit(habit.id);
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

/// A single habit row that watches its own parameters.
class _HabitListItem extends ConsumerWidget {
  final Habit habit;
  final VoidCallback onDelete;

  const _HabitListItem({
    required this.habit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paramsAsync = ref.watch(habitParameterNotifierProvider(habit.id));

    final params = paramsAsync.maybeWhen<List<HabitParameter>>(
      data: (p) => p,
      orElse: () => const [],
    );

    return HabitCard(
      habit: habit,
      parameters: params,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => HabitDetailPage(habit: habit),
        ),
      ),
      onDelete: onDelete,
    );
  }
}
