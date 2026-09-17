import 'package:flutter/material.dart';
import '../../domain/entities/habit_parameter.dart';

final class HabitParameterCard extends StatelessWidget {
  final HabitParameter param;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const HabitParameterCard({
    super.key,
    required this.param,
    this.onTap,
    this.onDelete,
  });

  static const _primaryBlue = Color(0xFF0058A3);

  Color _typeColor(String type) {
    switch (type) {
      case 'health':
        return const Color(0xFFE8445A);
      case 'food':
      case 'nutrition':
        return const Color(0xFFFF8C42);
      case 'fitness':
      case 'strength':
      case 'cardio':
        return _primaryBlue;
      case 'sleep':
      case 'recovery':
        return const Color(0xFF7C5CFC);
      case 'hydration':
        return const Color(0xFF00A8D6);
      case 'mindfulness':
        return const Color(0xFF5E9B7C);
      default:
        return _primaryBlue;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'health':
        return Icons.favorite;
      case 'food':
      case 'nutrition':
        return Icons.restaurant;
      case 'fitness':
        return Icons.fitness_center;
      case 'strength':
        return Icons.fitness_center;
      case 'cardio':
        return Icons.directions_run;
      case 'sleep':
        return Icons.bedtime;
      case 'hydration':
        return Icons.water_drop;
      case 'mindfulness':
        return Icons.self_improvement;
      case 'recovery':
        return Icons.healing;
      default:
        return Icons.check_circle_outline;
    }
  }

  String _durationLabel(int totalDays) {
    if (totalDays == 0) return 'today';
    final parts = <String>[];
    int r = totalDays;
    if (r >= 365) {
      parts.add('${r ~/ 365}y');
      r %= 365;
    }
    if (r >= 30) {
      parts.add('${r ~/ 30}m');
      r %= 30;
    }
    if (r >= 7) {
      parts.add('${r ~/ 7}w');
      r %= 7;
    }
    if (r > 0 || parts.isEmpty) parts.add('${r}d');
    return parts.join(' ');
  }

  int _days(DateTime? d) => d?.difference(DateTime.now()).inDays ?? -1;
  int _since(DateTime? d) =>
      d != null ? DateTime.now().difference(d).inDays : -1;

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(param.type);
    final icon = _typeIcon(param.type);
    final daysLeft = _days(param.endDate);
    final sinceStart = _since(param.startDate);
    final valueText = param.value == param.value.truncateToDouble()
        ? param.value.toInt().toString()
        : param.value.toString();
    final isUrgent = daysLeft >= 0 && daysLeft <= 3;

    final card = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: isUrgent
                  ? const Border(
                      left: BorderSide(color: Color(0xFFE8445A), width: 4),
                    )
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
              child: Row(
                children: [
                  // Leading type icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withAlpha(26),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 14),

                  // Title
                  Expanded(
                    child: Text(
                      param.description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Date-based values (stacked, icons aligned)
                  if (sinceStart >= 0 || daysLeft >= 0) ...[
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (sinceStart >= 0)
                          _DateLine(
                            icon: Icons.play_arrow,
                            label: _durationLabel(sinceStart),
                            color: Colors.grey.shade500,
                          ),
                        if (daysLeft >= 0)
                          _DateLine(
                            icon: Icons.flag,
                            label: daysLeft == 0 ? 'today' : _durationLabel(daysLeft),
                            color: daysLeft <= 7
                                ? const Color(0xFFE8445A)
                                : Colors.grey.shade500,
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(width: 8),

                  // Trailing value
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        valueText,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0058A3),
                          height: 1.2,
                        ),
                      ),
                      Text(
                        param.unit,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),

                  // Right chevron
                  Icon(Icons.chevron_right,
                      size: 22, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (onDelete != null) {
      return Dismissible(
        key: Key(param.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete habit?'),
                  content: Text('Remove "${param.description}"?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete',
                            style: TextStyle(color: Color(0xFFE8445A)))),
                  ],
                ),
              ) ??
              false;
        },
        background: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFE8445A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
        ),
        onDismissed: (_) => onDelete!(),
        child: card,
      );
    }
    return card;
  }
}

class _DateLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _DateLine({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            child: Icon(icon, size: 10, color: color),
          ),
          const SizedBox(width: 1),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
              height: 1.2,
            ),
          ),
        ],
      );
}
