import 'package:flutter/material.dart';

/// Visual identity of habit categories — the single source of truth for
/// category colour, icon and display label.
///
/// Previously duplicated in the card, detail page and statistics widgets;
/// centralised here so every slice renders categories identically.

/// The supported habit categories, in display order.
const habitTypes = <String>[
  'health',
  'fitness',
  'strength',
  'cardio',
  'nutrition',
  'hydration',
  'sleep',
  'mindfulness',
  'recovery',
];

Color habitTypeColor(String type) => switch (type) {
      'health' => const Color(0xFFE8445A),
      'food' || 'nutrition' => const Color(0xFFF08C2E),
      'fitness' || 'strength' || 'cardio' => const Color(0xFF0A66C2),
      'sleep' || 'recovery' => const Color(0xFF7C5CFC),
      'hydration' => const Color(0xFF00A8D6),
      'mindfulness' => const Color(0xFF4E9B70),
      _ => const Color(0xFF0A66C2),
    };

IconData habitTypeIcon(String type) => switch (type) {
      'health' => Icons.favorite,
      'food' || 'nutrition' => Icons.restaurant,
      'fitness' || 'strength' => Icons.fitness_center,
      'cardio' => Icons.directions_run,
      'sleep' => Icons.bedtime,
      'recovery' => Icons.healing,
      'hydration' => Icons.water_drop,
      'mindfulness' => Icons.self_improvement,
      _ => Icons.check_circle_outline,
    };

/// Human-readable category name, e.g. `'nutrition'` → `'Nutrition'`.
String habitTypeLabel(String type) =>
    type.isEmpty ? type : type[0].toUpperCase() + type.substring(1);
