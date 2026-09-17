import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../habit/habit.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/habit_avatar.dart';
import '../../../../shared/widgets/habit_type_style.dart';

/// Statistics screen — the app's "Insights" tab.
///
/// Read-only projection over habit state: watches the notifier (via the
/// habit slice's barrel) and derives counts in `build`. Never mutates state.
final class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(habitParameterNotifierProvider);
    final notifier = ref.read(habitParameterNotifierProvider.notifier);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => EmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Couldn\'t load insights',
        subtitle: '$err',
        action: IconButton.filled(
          onPressed: notifier.load,
          tooltip: 'Try again',
          icon: const Icon(Icons.refresh),
        ),
      ),
      data: (habits) {
        if (habits.isEmpty) {
          return const EmptyState(
            icon: Icons.insights_outlined,
            title: 'No insights yet',
            subtitle: 'Add habits on the Home tab to see your statistics here.',
          );
        }
        return _InsightsBody(habits: habits);
      },
    );
  }
}

final class _InsightsBody extends StatelessWidget {
  final List<HabitParameter> habits;

  const _InsightsBody({required this.habits});

  @override
  Widget build(BuildContext context) {
    final palette = context.habitizer;
    final now = DateTime.now();

    final active =
        habits.where((h) => h.endDate == null || h.endDate!.isAfter(now)).toList();
    final completed =
        habits.where((h) => h.endDate != null && h.endDate!.isBefore(now)).toList();
    final dueSoon = active
        .where((h) =>
            h.endDate != null && h.endDate!.difference(now).inDays <= 7)
        .toList()
      ..sort((a, b) => a.endDate!.compareTo(b.endDate!));

    final completionRate = habits.isEmpty ? 0.0 : completed.length / habits.length;

    final typeCounts = <String, int>{};
    for (final h in habits) {
      typeCounts[h.type] = (typeCounts[h.type] ?? 0) + 1;
    }
    final sortedTypes = typeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text('Insights', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 3),
          Text(
            'Your habit performance at a glance',
            style: TextStyle(fontSize: 13, color: palette.mutedText),
          ),
          const SizedBox(height: 16),

          // ── Hero: gradient summary with completion ring ──
          _HeroCard(
            total: habits.length,
            activeCount: active.length,
            completedCount: completed.length,
            completionRate: completionRate,
          ),
          const SizedBox(height: 12),

          // ── KPI row ──
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                  icon: Icons.play_circle_outline,
                  label: 'Active',
                  value: '${active.length}',
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _KpiCard(
                  icon: Icons.flag_outlined,
                  label: 'Completed',
                  value: '${completed.length}',
                  color: palette.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _KpiCard(
                  icon: Icons.schedule,
                  label: 'Due soon',
                  value: '${dueSoon.length}',
                  color: palette.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── By category ──
          _SectionCard(
            title: 'By category',
            child: Column(
              children: [
                for (final (i, e) in sortedTypes.indexed) ...[
                  if (i > 0) const SizedBox(height: 12),
                  _TypeBar(type: e.key, count: e.value, total: habits.length),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Due soon ──
          _SectionCard(
            title: 'Due soon',
            trailing: Text(
              '${dueSoon.length}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: palette.danger,
              ),
            ),
            child: dueSoon.isEmpty
                ? Text(
                    'Nothing due in the next 7 days. Nice pace!',
                    style: TextStyle(fontSize: 13, color: palette.mutedText),
                  )
                : Column(
                    children: [
                      for (final (i, h) in dueSoon.indexed) ...[
                        if (i > 0) Divider(height: 20, color: palette.border),
                        _DueSoonRow(habit: h),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Hero card ────────────────────────────────────────────────
final class _HeroCard extends StatelessWidget {
  final int total;
  final int activeCount;
  final int completedCount;
  final double completionRate;

  const _HeroCard({
    required this.total,
    required this.activeCount,
    required this.completedCount,
    required this.completionRate,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.habitizer;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.gradientStart, palette.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$total',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.0,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'habits tracked',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              // Completion ring
              SizedBox(
                width: 78,
                height: 78,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: completionRate,
                      strokeWidth: 7,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    Center(
                      child: Text(
                        '${(completionRate * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _HeroStat(label: 'Active', value: '$activeCount'),
              const SizedBox(width: 18),
              _HeroStat(label: 'Completed', value: '$completedCount'),
            ],
          ),
        ],
      ),
    );
  }
}

final class _HeroStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            '$value ',
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            label.toLowerCase(),
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ],
      );
}

// ── KPI card ─────────────────────────────────────────────────
final class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.habitizer;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: palette.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section card ─────────────────────────────────────────────
final class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    final palette = context.habitizer;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── Category bar ─────────────────────────────────────────────
final class _TypeBar extends StatelessWidget {
  final String type;
  final int count;
  final int total;

  const _TypeBar({required this.type, required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    final color = habitTypeColor(type);
    final pct = total > 0 ? count / total : 0.0;

    return Row(
      children: [
        Icon(habitTypeIcon(type), size: 19, color: color),
        const SizedBox(width: 10),
        SizedBox(
          width: 78,
          child: Text(
            habitTypeLabel(type),
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.14),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 24,
          child: Text(
            '$count',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Due-soon row ─────────────────────────────────────────────
final class _DueSoonRow extends StatelessWidget {
  final HabitParameter habit;

  const _DueSoonRow({required this.habit});

  @override
  Widget build(BuildContext context) {
    final palette = context.habitizer;
    final daysLeft = habit.endDate!.difference(DateTime.now()).inDays;

    return Row(
      children: [
        HabitAvatar(type: habit.type, size: 36),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                habit.description,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                habitTypeLabel(habit.type),
                style: TextStyle(fontSize: 12, color: palette.mutedText),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: palette.danger.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            daysLeft <= 0 ? 'today' : '${daysLeft}d left',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: palette.danger,
            ),
          ),
        ),
      ],
    );
  }
}
