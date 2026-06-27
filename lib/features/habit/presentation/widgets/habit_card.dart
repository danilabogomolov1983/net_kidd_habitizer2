import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_parameter.dart';

final class HabitCard extends ConsumerWidget {
  final Habit habit;
  final List<HabitParameter> parameters;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    this.parameters = const [],
    this.onTap,
    this.onDelete,
  });

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'daily':
        return Icons.today;
      case 'weekly':
        return Icons.date_range;
      case 'monthly':
        return Icons.calendar_month;
      case 'counter':
        return Icons.plus_one;
      case 'timer':
        return Icons.timer;
      default:
        return Icons.self_improvement;
    }
  }

  Color _typeColor(String type, ColorScheme cs) {
    switch (type.toLowerCase()) {
      case 'daily':
        return cs.primary;
      case 'weekly':
        return cs.tertiary;
      case 'monthly':
        return cs.secondary;
      case 'counter':
        return const Color(0xFFE91E63);
      case 'timer':
        return const Color(0xFFFF9800);
      default:
        return cs.primary;
    }
  }

  /// Latest parameter (sorted by created_at desc — data source already does this).
  HabitParameter? get _latest =>
      parameters.isNotEmpty ? parameters.first : null;

  int? _daysFromStart() {
    final p = _latest;
    if (p?.startDate == null) return null;
    return DateTime.now().difference(p!.startDate!).inDays;
  }

  int? _daysTillEnd() {
    final p = _latest;
    if (p?.endDate == null) return null;
    return p!.endDate!.difference(DateTime.now()).inDays;
  }

  double? _progress() {
    final p = _latest;
    if (p?.startDate == null || p?.endDate == null) return null;
    final total = p!.endDate!.difference(p.startDate!).inDays;
    if (total <= 0) return null;
    final elapsed = DateTime.now().difference(p.startDate!).inDays;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final typeColor = _typeColor(habit.type, cs);
    final latest = _latest;
    final daysFrom = _daysFromStart();
    final daysTill = _daysTillEnd();
    final progress = _progress();

    final valueText = latest != null
        ? (latest.value == latest.value.truncateToDouble()
            ? latest.value.toInt().toString()
            : latest.value.toString())
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row: icon, name, type pill, actions ────────────────
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: typeColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(_typeIcon(habit.type),
                        color: typeColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: typeColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            habit.type,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: typeColor,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: cs.error.withAlpha(180), size: 20),
                      onPressed: onDelete,
                      tooltip: 'Delete habit',
                      visualDensity: VisualDensity.compact,
                    ),
                  Icon(Icons.chevron_right,
                      color: cs.onSurface.withAlpha(80)),
                ],
              ),

              // ── Bottom section: parameter summary ─────────────────────
              if (latest != null) ...[
                const SizedBox(height: 12),
                Divider(height: 1, color: cs.outlineVariant.withAlpha(80)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Value + unit badge
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer.withAlpha(100),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                valueText!,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: cs.onPrimaryContainer,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              latest.measureUnit,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.onPrimaryContainer.withAlpha(180),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Day counters
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow_rounded,
                              size: 15,
                              color: daysFrom != null
                                  ? cs.primary.withAlpha(180)
                                  : cs.onSurface.withAlpha(80)),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              daysFrom == null
                                  ? 'n.a.'
                                  : daysFrom == 0
                                      ? 'today'
                                      : daysFrom == 1
                                          ? '1 day'
                                          : '$daysFrom d',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: daysFrom != null
                                    ? cs.primary
                                    : cs.onSurface.withAlpha(100),
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('·',
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.onSurface.withAlpha(60))),
                    ),
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.flag_rounded,
                              size: 15,
                              color: daysTill != null
                                  ? (daysTill <= 7
                                      ? cs.error.withAlpha(200)
                                      : cs.tertiary.withAlpha(180))
                                  : cs.onSurface.withAlpha(80)),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              daysTill == null
                                  ? 'n.a.'
                                  : daysTill == 0
                                      ? 'ends today'
                                      : daysTill == 1
                                          ? '1 day left'
                                          : '$daysTill d left',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: daysTill != null
                                    ? (daysTill <= 7 ? cs.error : cs.tertiary)
                                    : cs.onSurface.withAlpha(100),
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Parameter count badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withAlpha(120),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${parameters.length}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurface.withAlpha(160),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                // Progress bar (if date range)
                if (progress != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: cs.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress < 0.7 ? cs.primary : cs.error,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
