import 'package:equatable/equatable.dart';
import '../../../../core/domain/base_types.dart';

/// A habit parameter the user tracks.
///
/// Fields: [type] (health, food, fitness, sleep), [description],
/// optional [startDate]/[endDate], [value] and [unit].
final class HabitParameter extends Equatable implements IEntity {
  @override
  final String id;
  final String type;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final double value;
  final String unit;
  final DateTime createdAt;

  const HabitParameter({
    required this.id,
    required this.type,
    required this.description,
    this.startDate,
    this.endDate,
    required this.value,
    required this.unit,
    required this.createdAt,
  });

  factory HabitParameter.create({
    required String id,
    required String type,
    required String description,
    DateTime? startDate,
    DateTime? endDate,
    required double value,
    required String unit,
  }) {
    return HabitParameter(
      id: id,
      type: type,
      description: description,
      startDate: startDate,
      endDate: endDate,
      value: value,
      unit: unit,
      createdAt: DateTime.now(),
    );
  }

  HabitParameter copyWith({
    String? id,
    String? type,
    String? description,
    Object? startDate = _sentinel,
    Object? endDate = _sentinel,
    double? value,
    String? unit,
    DateTime? createdAt,
  }) {
    return HabitParameter(
      id: id ?? this.id,
      type: type ?? this.type,
      description: description ?? this.description,
      startDate: startDate == _sentinel ? this.startDate : startDate as DateTime?,
      endDate: endDate == _sentinel ? this.endDate : endDate as DateTime?,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static const _sentinel = Object();

  @override
  List<Object?> get props => [
        id,
        type,
        description,
        startDate,
        endDate,
        value,
        unit,
        createdAt,
      ];
}
