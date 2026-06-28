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

  HabitParameter? get _latest =>
      parameters.isNotEmpty ? parameters.first : null;

  int? _day(DateTime? d) {
    if (d == null) return null;
    return d.difference(DateTime.now()).inDays;
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
    final days = latest != null ? _day(latest.endDate) : null;
    final progress = _progress();

    final valueText = latest != null
        ? (latest.value == latest.value.truncateToDouble()
            ? latest.value.toInt().toString()
            : latest.value.toString())
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              // Icon
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: typeColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(9),
                ),
                child:
                    Icon(_typeIcon(habit.type), color: typeColor, size: 18),
              ),
              const SizedBox(width: 8),

              // Name + type
              Flexible(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      habit.type,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: typeColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Parameter info
              if (latest != null) ...[
                Flexible(
                  flex: 3,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Value + unit
                      Flexible(
                        child: Text(
                          '$valueText ${latest.measureUnit}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Day counter
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.flag_rounded,
                                size: 12,
                                color: days != null && days <= 7
                                    ? cs.error
                                    : cs.onSurface.withAlpha(120)),
                            const SizedBox(width: 2),
                            Text(
                              days == null
                                  ? 'n.a.'
                                  : days == 0
                                      ? 'ends'
                                      : '${days}d',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                                color: days != null && days <= 7
                                    ? cs.error
                                    : cs.onSurface.withAlpha(160),
                              ),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Progress bar
                      if (progress != null)
                        Flexible(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 3,
                              backgroundColor: cs.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progress < 0.7 ? cs.primary : cs.error,
                              ),
                            ),
                          ),
                        )
                      else
                        Flexible(
                          child: Text(
                            '${parameters.length}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.onSurface.withAlpha(100),
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // Delete button
              if (onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      size: 18, color: cs.error.withAlpha(140)),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                  visualDensity: VisualDensity.compact,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
