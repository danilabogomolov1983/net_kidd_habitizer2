import '../../domain/entities/habit.dart';

final class HabitDto {
  final String id;
  final String type;
  final String name;
  final String createdAt;

  const HabitDto({
    required this.id,
    required this.type,
    required this.name,
    required this.createdAt,
  });

  factory HabitDto.fromMap(Map<String, Object?> map) {
    return HabitDto(
      id: map['id'] as String,
      type: map['type'] as String,
      name: map['name'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'type': type,
        'name': name,
        'created_at': createdAt,
      };
}

/// Pure function: [HabitDto] → [Habit].
Habit habitFromDto(HabitDto dto) => Habit(
      id: dto.id,
      type: dto.type,
      name: dto.name,
      createdAt: DateTime.parse(dto.createdAt),
    );

/// Pure function: [Habit] → [HabitDto].
HabitDto habitToDto(Habit habit) => HabitDto(
      id: habit.id,
      type: habit.type,
      name: habit.name,
      createdAt: habit.createdAt.toIso8601String(),
    );
