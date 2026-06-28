import '../../domain/entities/habit_parameter.dart';

final class HabitParameterDto {
  final String id;
  final String type;
  final String description;
  final String? startDate;
  final String? endDate;
  final double value;
  final String unit;
  final String createdAt;

  const HabitParameterDto({
    required this.id,
    required this.type,
    required this.description,
    this.startDate,
    this.endDate,
    required this.value,
    required this.unit,
    required this.createdAt,
  });

  factory HabitParameterDto.fromMap(Map<String, Object?> map) {
    return HabitParameterDto(
      id: (map['id'] as String?) ?? '',
      type: (map['type'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      startDate: map['start_date'] as String?,
      endDate: map['end_date'] as String?,
      value: (map['value'] as num?)?.toDouble() ?? 0,
      unit: (map['unit'] as String?) ?? '',
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'type': type,
        'description': description,
        'start_date': startDate,
        'end_date': endDate,
        'value': value,
        'unit': unit,
        'created_at': createdAt,
      };
}

HabitParameter paramFromDto(HabitParameterDto dto) => HabitParameter(
      id: dto.id,
      type: dto.type,
      description: dto.description,
      startDate: dto.startDate != null ? DateTime.tryParse(dto.startDate!) : null,
      endDate: dto.endDate != null ? DateTime.tryParse(dto.endDate!) : null,
      value: dto.value,
      unit: dto.unit,
      createdAt: DateTime.parse(dto.createdAt),
    );

HabitParameterDto paramToDto(HabitParameter p) => HabitParameterDto(
      id: p.id,
      type: p.type,
      description: p.description,
      startDate: p.startDate?.toIso8601String(),
      endDate: p.endDate?.toIso8601String(),
      value: p.value,
      unit: p.unit,
      createdAt: p.createdAt.toIso8601String(),
    );
