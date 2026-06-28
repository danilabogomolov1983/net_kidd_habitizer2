import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/habit_parameter_notifier.dart';
import '../widgets/habit_parameter_card.dart';
import 'habit_parameter_detail_page.dart';

final class HabitParameterListPage extends ConsumerWidget {
  const HabitParameterListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(habitParameterNotifierProvider);
    final notifier = ref.read(habitParameterNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Habits')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 8),
            Text('Error: $err'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => notifier.load(), child: const Text('Retry')),
          ]),
        ),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.self_improvement, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('No habits yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600)),
              ]),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => notifier.load(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: list.length,
              itemBuilder: (ctx, i) {
                final p = list[i];
                return HabitParameterCard(
                  param: p,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => HabitParameterDetailPage(param: p)),
                  ),
                  onDelete: () => notifier.delete(p.id),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HabitParameterDetailPage()),
        ),
        tooltip: 'New',
        child: const Icon(Icons.add),
      ),
    );
  }
}
