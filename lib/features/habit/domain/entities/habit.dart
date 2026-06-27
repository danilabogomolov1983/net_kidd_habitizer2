import 'package:equatable/equatable.dart';
import '../../../../core/domain/base_types.dart';

/// A habit that the user wants to track.
///
/// Habits have a [type] (e.g. "daily", "weekly", "counter") and a [name].
final class Habit extends Equatable implements IEntity {
  @override
  final String id;
  final String type;
  final String name;
  final DateTime createdAt;

  const Habit({
    required this.id,
    required this.type,
    required this.name,
    required this.createdAt,
  });

  factory Habit.create({
    required String id,
    required String type,
    required String name,
  }) {
    return Habit(
      id: id,
      type: type,
      name: name,
      createdAt: DateTime.now(),
    );
  }

  Habit copyWith({
    String? id,
    String? type,
    String? name,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, type, name, createdAt];
}
