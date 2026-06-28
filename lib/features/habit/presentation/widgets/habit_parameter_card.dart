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
      case 'health': return const Color(0xFFE8445A);
      case 'food': return const Color(0xFFFF8C42);
      case 'fitness': return _primaryBlue;
      case 'sleep': return const Color(0xFF7C5CFC);
      default: return _primaryBlue;
    }
  }

  String _durationLabel(int totalDays) {
    if (totalDays == 0) return 'now';
    final parts = <String>[];
    int r = totalDays;
    if (r >= 365) { parts.add('${r ~/ 365}y'); r %= 365; }
    if (r >= 30) { parts.add('${r ~/ 30}m'); r %= 30; }
    if (r >= 7) { parts.add('${r ~/ 7}w'); r %= 7; }
    if (r > 0 || parts.isEmpty) parts.add('${r}d');
    return parts.join(' ');
  }

  int _days(DateTime? d) => d?.difference(DateTime.now()).inDays ?? -1;
  int _since(DateTime? d) => d != null ? DateTime.now().difference(d).inDays : -1;

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(param.type);
    final daysLeft = _days(param.endDate);
    final sinceStart = _since(param.startDate);
    final valueText = param.value == param.value.truncateToDouble()
        ? param.value.toInt().toString()
        : param.value.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                // Type label
                Text(param.type,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
                const SizedBox(width: 10),
                // Description
                Flexible(
                  child: Text(param.description,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E)),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                // Value + unit
                Text('$valueText${param.unit}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                        color: _primaryBlue)),
                const SizedBox(width: 8),
                // Dates
                if (param.startDate != null)
                  _MiniDate(icon: Icons.play_circle_outline,
                      label: '${param.startDate!.month}/${param.startDate!.day}',
                      color: _primaryBlue),
                if (param.startDate != null || param.endDate != null)
                  Text('·', style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                if (param.endDate != null)
                  _MiniDate(icon: Icons.flag_circle_outlined,
                      label: '${param.endDate!.month}/${param.endDate!.day}',
                      color: const Color(0xFF7C5CFC)),
                // Stats
                if (sinceStart >= 0) ...[
                  const SizedBox(width: 6),
                  Text('${_durationLabel(sinceStart)} ago',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _primaryBlue)),
                ],
                if (daysLeft >= 0) ...[
                  const SizedBox(width: 4),
                  Text(daysLeft == 0 ? 'ends' : '${_durationLabel(daysLeft)} left',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                          color: daysLeft <= 7 ? const Color(0xFFE8445A) : const Color(0xFF7C5CFC))),
                ],
                if (onDelete != null) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFFB0B0C0)),
                    onPressed: onDelete, visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniDate extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MiniDate({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12, color: color),
      const SizedBox(width: 2),
      Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    ],
  );
}
