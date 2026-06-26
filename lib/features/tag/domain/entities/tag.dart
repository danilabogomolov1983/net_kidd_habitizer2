import 'package:equatable/equatable.dart';
import '../../../../core/domain/base_types.dart';

/// A tag (label / category) that can be associated with tasks.
///
/// Tags have a unique [name] and a display [color] (hex string like `#FF5722`).
final class Tag extends Equatable implements IEntity {
  @override
  final String id;
  final String name;
  final String color;
  final DateTime createdAt;

  const Tag({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
  });

  factory Tag.create({
    required String id,
    required String name,
    String color = '#2196F3',
  }) {
    return Tag(
      id: id,
      name: name,
      color: color,
      createdAt: DateTime.now(),
    );
  }

  Tag copyWith({
    String? id,
    String? name,
    String? color,
    DateTime? createdAt,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, color, createdAt];
}
