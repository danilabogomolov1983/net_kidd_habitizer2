import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/habit_parameter.dart';

/// LinkedIn-style feed filter pills shown on the home tab.
///
/// Browsing concern of the habit slice, alongside `searchQueryProvider`.
enum HabitFeedFilter { all, active, dueSoon, completed }

extension HabitFeedFilterX on HabitFeedFilter {
  String get label => switch (this) {
        HabitFeedFilter.all => 'All',
        HabitFeedFilter.active => 'Active',
        HabitFeedFilter.dueSoon => 'Due soon',
        HabitFeedFilter.completed => 'Completed',
      };

  /// Whether [habit] belongs in this filter bucket.
  bool accepts(HabitParameter habit) {
    final now = DateTime.now();
    final end = habit.endDate;
    final completed = end != null && end.isBefore(now);
    return switch (this) {
      HabitFeedFilter.all => true,
      HabitFeedFilter.active => !completed,
      HabitFeedFilter.dueSoon =>
        !completed && end != null && end.difference(now).inDays <= 7,
      HabitFeedFilter.completed => completed,
    };
  }

  /// Number of habits in [habits] matching this bucket (for the pill counter).
  int countOf(Iterable<HabitParameter> habits) =>
      habits.where(accepts).length;
}

final habitFeedFilterProvider =
    StateProvider<HabitFeedFilter>((ref) => HabitFeedFilter.all);
