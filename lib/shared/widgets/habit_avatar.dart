import 'package:flutter/material.dart';
import 'habit_type_style.dart';

/// Circular category avatar — the LinkedIn-style "profile picture" of a habit.
///
/// A tinted circle in the category colour with the category glyph inside.
final class HabitAvatar extends StatelessWidget {
  final String type;

  /// Diameter of the circle. Icon scales proportionally.
  final double size;

  /// Optional white/grey ring around the avatar (used on hero surfaces).
  final Color? ringColor;
  final double ringWidth;

  const HabitAvatar({
    super.key,
    required this.type,
    this.size = 44,
    this.ringColor,
    this.ringWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final color = habitTypeColor(type);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
        border: ringColor == null
            ? null
            : Border.all(color: ringColor!, width: ringWidth),
      ),
      child: Icon(
        habitTypeIcon(type),
        size: size * 0.5,
        color: color,
      ),
    );
  }
}
