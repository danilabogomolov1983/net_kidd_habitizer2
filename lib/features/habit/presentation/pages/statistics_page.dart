import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/habit_parameter_notifier.dart';

final class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(habitParameterNotifierProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text('Could not load stats',
            style: TextStyle(color: Colors.grey.shade600)),
      ),
      data: (habits) {
        if (habits.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bar_chart, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('No data yet',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.grey.shade500)),
                const SizedBox(height: 8),
                Text('Add habits to see your statistics',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey.shade400)),
              ],
            ),
          );
        }

        final now = DateTime.now();
        final active =
            habits.where((h) => h.endDate == null || h.endDate!.isAfter(now));
        final completed = habits
            .where((h) => h.endDate != null && h.endDate!.isBefore(now));
        final typeCounts = <String, int>{};
        for (final h in habits) {
          typeCounts[h.type] = (typeCounts[h.type] ?? 0) + 1;
        }
        final sortedTypes = typeCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        const primaryBlue = Color(0xFF0058A3);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Summary cards ──
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                        icon: Icons.checklist,
                        label: 'Total',
                        value: '${habits.length}',
                        color: primaryBlue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                        icon: Icons.play_circle_outline,
                        label: 'Active',
                        value: '${active.length}',
                        color: const Color(0xFF7C5CFC)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                        icon: Icons.flag_circle_outlined,
                        label: 'Done',
                        value: '${completed.length}',
                        color: const Color(0xFF4CAF50)),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── By type ──
              Text('By category',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ...sortedTypes.map((e) => _TypeBar(
                    type: e.key,
                    count: e.value,
                    total: habits.length,
                  )),
            ],
          ),
        );
      },
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

// ── Type bar ───────────────────────────────────────────────────
class _TypeBar extends StatelessWidget {
  final String type;
  final int count;
  final int total;
  const _TypeBar({
    required this.type,
    required this.count,
    required this.total,
  });

  static const _colors = <String, Color>{
    'health': Color(0xFFE8445A),
    'food': Color(0xFFFF8C42),
    'nutrition': Color(0xFFFF8C42),
    'fitness': Color(0xFF0058A3),
    'strength': Color(0xFF0058A3),
    'cardio': Color(0xFF0058A3),
    'sleep': Color(0xFF7C5CFC),
    'recovery': Color(0xFF7C5CFC),
    'hydration': Color(0xFF00A8D6),
    'mindfulness': Color(0xFF5E9B7C),
  };

  static const _icons = <String, IconData>{
    'health': Icons.favorite,
    'food': Icons.restaurant,
    'nutrition': Icons.restaurant,
    'fitness': Icons.fitness_center,
    'strength': Icons.fitness_center,
    'cardio': Icons.directions_run,
    'sleep': Icons.bedtime,
    'recovery': Icons.healing,
    'hydration': Icons.water_drop,
    'mindfulness': Icons.self_improvement,
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[type] ?? const Color(0xFF0058A3);
    final icon = _icons[type] ?? Icons.check_circle_outline;
    final pct = total > 0 ? count / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          SizedBox(
            width: 64,
            child: Text(type,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 10,
                backgroundColor: color.withAlpha(30),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 28,
            child: Text('$count',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ),
        ],
      ),
    );
  }
}
