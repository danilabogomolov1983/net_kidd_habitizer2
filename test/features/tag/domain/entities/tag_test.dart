import 'package:flutter_test/flutter_test.dart';
import 'package:net_kidd_habitizer2/features/tag/domain/entities/tag.dart';

void main() {
  group('Tag entity', () {
    test('factory create sets id, name, color, createdAt', () {
      final tag = Tag.create(id: 'tag1', name: 'Work', color: '#FF5722');
      expect(tag.id, 'tag1');
      expect(tag.name, 'Work');
      expect(tag.color, '#FF5722');
      expect(tag.createdAt, isA<DateTime>());
    });

    test('create uses default blue color', () {
      final tag = Tag.create(id: 'tag2', name: 'Personal');
      expect(tag.color, '#2196F3');
    });

    test('copyWith returns new instance', () {
      final tag = Tag.create(id: 'tag3', name: 'Health');
      final updated = tag.copyWith(name: 'Fitness');
      expect(updated.name, 'Fitness');
      expect(updated.id, tag.id);
      expect(updated.color, tag.color);
    });

    test('equatable props', () {
      final tag = Tag.create(id: 'tag4', name: 'Study');
      expect(tag.props.length, 4);
    });
  });
}
