import '../../domain/entities/tag.dart';

final class TagDto {
  final String id;
  final String name;
  final String color;
  final String createdAt;

  const TagDto({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
  });

  factory TagDto.fromMap(Map<String, Object?> map) {
    return TagDto(
      id: map['id'] as String,
      name: map['name'] as String,
      color: map['color'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'color': color,
        'created_at': createdAt,
      };
}

/// Pure function: [TagDto] → [Tag].
Tag tagFromDto(TagDto dto) => Tag(
      id: dto.id,
      name: dto.name,
      color: dto.color,
      createdAt: DateTime.parse(dto.createdAt),
    );

/// Pure function: [Tag] → [TagDto].
TagDto tagToDto(Tag tag) => TagDto(
      id: tag.id,
      name: tag.name,
      color: tag.color,
      createdAt: tag.createdAt.toIso8601String(),
    );
