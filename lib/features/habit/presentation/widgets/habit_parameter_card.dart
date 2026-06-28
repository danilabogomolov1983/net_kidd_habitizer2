import 'package:flutter/material.dart';
import '../../domain/entities/habit_parameter.dart';

final class HabitParameterCard extends StatelessWidget {
  final HabitParameter param;
  final VoidCallback? onTap;

  const HabitParameterCard({
    super.key,
    required this.param,
    this.onTap,
  });

  static const _primaryBlue = Color(0xFF0058A3);

  Color _typeColor(String type) {
    switch (type) {
      case 'health':
        return const Color(0xFFE8445A);
      case 'food':
        return const Color(0xFFFF8C42);
      case 'fitness':
        return _primaryBlue;
      case 'sleep':
        return const Color(0xFF7C5CFC);
      default:
        return _primaryBlue;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'health':
        return Icons.favorite;
      case 'food':
        return Icons.restaurant;
      case 'fitness':
        return Icons.fitness_center;
      case 'sleep':
        return Icons.bedtime;
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

    // Subtitle:  "health  ·  started 2w ago  ·  5d left"
    final subtitlePieces = <String>[param.type];
    if (sinceStart >= 0) {
      subtitlePieces.add('started ${_durationLabel(sinceStart)} ago');
    }
    if (daysLeft >= 0) {
      subtitlePieces.add(
          daysLeft == 0 ? 'ends today' : '${_durationLabel(daysLeft)} left');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Leading type icon — 48px touch target
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

                // Title + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
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
                      const SizedBox(height: 4),
                      Text(
                        subtitlePieces.join('  ·  '),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

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
                        color: _primaryBlue,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
