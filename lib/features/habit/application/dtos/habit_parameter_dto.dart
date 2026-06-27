import '../../domain/entities/habit_parameter.dart';

final class HabitParameterDto {
  final String id;
  final String habitId;
  final String? startDate;
  final String? endDate;
  final double value;
  final String measureUnit;
  final String createdAt;

  const HabitParameterDto({
    required this.id,
    required this.habitId,
    this.startDate,
    this.endDate,
    required this.value,
    required this.measureUnit,
    required this.createdAt,
  });

  factory HabitParameterDto.fromMap(Map<String, Object?> map) {
    return HabitParameterDto(
      id: map['id'] as String,
      habitId: map['habit_id'] as String,
      startDate: map['start_date'] as String?,
      endDate: map['end_date'] as String?,
      value: (map['value'] as num).toDouble(),
      measureUnit: map['measure_unit'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'habit_id': habitId,
        'start_date': startDate,
        'end_date': endDate,
        'value': value,
        'measure_unit': measureUnit,
        'created_at': createdAt,
      };
}

/// Pure function: [HabitParameterDto] → [HabitParameter].
HabitParameter habitParameterFromDto(HabitParameterDto dto) => HabitParameter(
      id: dto.id,
      habitId: dto.habitId,
      startDate: dto.startDate != null ? DateTime.tryParse(dto.startDate!) : null,
      endDate: dto.endDate != null ? DateTime.tryParse(dto.endDate!) : null,
      value: dto.value,
      measureUnit: dto.measureUnit,
      createdAt: DateTime.parse(dto.createdAt),
    );

/// Pure function: [HabitParameter] → [HabitParameterDto].
HabitParameterDto habitParameterToDto(HabitParameter param) => HabitParameterDto(
      id: param.id,
      habitId: param.habitId,
      startDate: param.startDate?.toIso8601String(),
      endDate: param.endDate?.toIso8601String(),
      value: param.value,
      measureUnit: param.measureUnit,
      createdAt: param.createdAt.toIso8601String(),
    );
