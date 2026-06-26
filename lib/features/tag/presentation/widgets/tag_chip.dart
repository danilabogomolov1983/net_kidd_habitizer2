import 'package:flutter/material.dart';
import '../../domain/entities/tag.dart';

final class TagChipWidget extends StatelessWidget {
  final Tag tag;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TagChipWidget({
    super.key,
    required this.tag,
    this.onTap,
    this.onDelete,
  });

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(tag.color);
    return Chip(
      label: Text(tag.name, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      backgroundColor: color.withAlpha(30),
      side: BorderSide(color: color.withAlpha(100)),
      onDeleted: onDelete,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
