import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/habit_avatar.dart';
import '../../../../shared/widgets/habit_type_style.dart';
import '../../domain/entities/habit_parameter.dart';

/// LinkedIn-post-style feed card for a habit.
///
/// Anatomy (mirroring a LinkedIn post): avatar + title + meta line + overflow
/// menu, a "body" (target value + status), and an action row
/// (Log / Edit / Delete) instead of Like / Comment / Repost / Send.
final class HabitParameterCard extends StatelessWidget {
  final HabitParameter param;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const HabitParameterCard({
    super.key,
    required this.param,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.habitizer;
    final typeColor = habitTypeColor(param.type);

    final now = DateTime.now();
    final end = param.endDate;
    final start = param.startDate;
    final daysLeft = end != null ? end.difference(now).inDays : -1;
    final isCompleted = daysLeft < 0;
    final isDueSoon = !isCompleted && daysLeft <= 7;

    // Progress between start and end date (only meaningful when both exist).
    double? progress;
    String? progressLabel;
    if (start != null && end != null && !isCompleted) {
      final total = end.difference(start).inDays;
      final elapsed = now.difference(start).inDays.clamp(0, total == 0 ? 0 : total);
      progress = total <= 0 ? 1.0 : (elapsed / total).clamp(0.0, 1.0);
      progressLabel = daysLeft == 0 ? 'ends today' : '${_durationLabel(daysLeft)} left';
    }

    final meta = _metaLine(param.type, start, end, now);
    final valueText = param.value == param.value.truncateToDouble()
        ? param.value.toInt().toString()
        : param.value.toString();

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: avatar, title, meta, overflow menu ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HabitAvatar(type: param.type, size: 46),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          param.description,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          meta,
                          style: TextStyle(
                            fontSize: 12,
                            color: palette.mutedText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_horiz,
                        size: 22, color: palette.mutedText),
                    tooltip: 'More',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _showMenu(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Body: target value + status chip ──
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            valueText,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              color: typeColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            param.unit,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: palette.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusChip(
                      completed: isCompleted,
                      dueSoon: isDueSoon,
                      daysLeft: daysLeft,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // ── Progress bar (when both dates are set) ──
              if (progress != null) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: typeColor.withValues(alpha: 0.14),
                          valueColor: AlwaysStoppedAnimation(typeColor),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            '${(progress * 100).round()}%',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: typeColor,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            progressLabel!,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isDueSoon
                                  ? palette.danger
                                  : palette.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
              ],

              // ── Action row (Like / Comment / Share equivalent) ──
              Divider(height: 1, color: palette.border),
              Row(
                children: [
                  _ActionItem(
                    icon: Icons.add_task_outlined,
                    label: 'Log',
                    onTap: onTap,
                  ),
                  _ActionItem(
                    icon: Icons.mode_edit_outline,
                    label: 'Edit',
                    onTap: onEdit,
                  ),
                  _ActionItem(
                    icon: Icons.delete_outline,
                    label: 'Delete',
                    onTap: onDelete == null
                        ? null
                        : () => _confirmDelete(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Overflow menu: LinkedIn-style bottom sheet ─────────────
  void _showMenu(BuildContext context) {
    final palette = context.habitizer;
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6),
            ListTile(
              leading: const Icon(Icons.add_task_outlined),
              title: const Text('Log progress'),
              onTap: () {
                Navigator.pop(sheetCtx);
                onTap?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.mode_edit_outline),
              title: const Text('Edit habit'),
              onTap: () {
                Navigator.pop(sheetCtx);
                onEdit?.call();
              },
            ),
            if (onDelete != null)
              ListTile(
                leading:
                    Icon(Icons.delete_outline, color: palette.danger),
                title: Text('Delete habit',
                    style: TextStyle(color: palette.danger)),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _confirmDelete(context);
                },
              ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete habit?'),
            content: Text('Remove "${param.description}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Delete',
                    style: TextStyle(color: context.habitizer.danger)),
              ),
            ],
          ),
        ) ??
        false;
    if (confirmed) onDelete?.call();
  }

  // ── Helpers ────────────────────────────────────────────────
  static String _durationLabel(int totalDays) {
    if (totalDays == 0) return 'today';
    final parts = <String>[];
    var r = totalDays;
    if (r >= 365) {
      parts.add('${r ~/ 365}y');
      r %= 365;
    }
    if (r >= 30) {
      parts.add('${r ~/ 30}mo');
      r %= 30;
    }
    if (r >= 7) {
      parts.add('${r ~/ 7}w');
      r %= 7;
    }
    if (r > 0 || parts.isEmpty) parts.add('${r}d');
    return parts.join(' ');
  }

  static String _metaLine(String type, DateTime? start, DateTime? end, DateTime now) {
    final category = habitTypeLabel(type);
    if (end != null && end.isBefore(now)) {
      final ago = now.difference(end).inDays;
      return '$category · ended ${_durationLabel(ago)} ago';
    }
    if (end != null) {
      final left = end.difference(now).inDays;
      return left == 0
          ? '$category · ends today'
          : '$category · ends in ${_durationLabel(left)}';
    }
    if (start != null) {
      final since = now.difference(start).inDays;
      return since == 0
          ? '$category · started today'
          : '$category · started ${_durationLabel(since)} ago';
    }
    return category;
  }
}

// ── Status chip ──────────────────────────────────────────────
final class _StatusChip extends StatelessWidget {
  final bool completed;
  final bool dueSoon;
  final int daysLeft;

  const _StatusChip({
    required this.completed,
    required this.dueSoon,
    required this.daysLeft,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.habitizer;
    final scheme = Theme.of(context).colorScheme;

    final (Color color, String label) = switch ((
      completed,
      dueSoon,
      daysLeft,
    )) {
      (true, _, _) => (palette.success, 'Completed'),
      (false, true, _) => (
          palette.danger,
          daysLeft == 0 ? 'Ends today' : '${daysLeft}d left'
        ),
      (false, false, >= 1) => (palette.mutedText, 'Active'),
      _ => (scheme.primary, 'Active'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ── Action row item ──────────────────────────────────────────
final class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionItem({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.habitizer;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 19, color: palette.mutedText),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: palette.mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
