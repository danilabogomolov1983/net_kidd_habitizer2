import 'package:equatable/equatable.dart';
import '../../../../core/domain/base_types.dart';

/// A measurable parameter associated with a [Habit].
///
/// Each parameter tracks a numeric [value] with a [measureUnit]
/// (e.g. "minutes", "kg", "reps"). [startDate] and [endDate] are optional
/// and define the tracking window.
final class HabitParameter extends Equatable implements IEntity {
  @override
  final String id;
  final String habitId;
  final DateTime? startDate;
  final DateTime? endDate;
  final double value;
  final String measureUnit;
  final DateTime createdAt;

  const HabitParameter({
    required this.id,
    required this.habitId,
    this.startDate,
    this.endDate,
    required this.value,
    required this.measureUnit,
    required this.createdAt,
  });

  factory HabitParameter.create({
    required String id,
    required String habitId,
    DateTime? startDate,
    DateTime? endDate,
    required double value,
    required String measureUnit,
  }) {
    return HabitParameter(
      id: id,
      habitId: habitId,
      startDate: startDate,
      endDate: endDate,
      value: value,
      measureUnit: measureUnit,
      createdAt: DateTime.now(),
    );
  }

  HabitParameter copyWith({
    String? id,
    String? habitId,
    DateTime? startDate,
    DateTime? endDate,
    double? value,
    String? measureUnit,
    DateTime? createdAt,
  }) {
    return HabitParameter(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      value: value ?? this.value,
      measureUnit: measureUnit ?? this.measureUnit,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        habitId,
        startDate,
        endDate,
        value,
        measureUnit,
        createdAt,
      ];
}
